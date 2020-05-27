package Cor::Parser;
# ABSTRACT: Parser for the Cor syntax

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

use PPR;

use List::Util;

use Cor::Parser::ASTBuilder;

our @_COR_USE_STATEMENTS;
our $_COR_CURRENT_MODULE;
our $_COR_CURRENT_META;
our $_COR_CURRENT_REFERENCE;
our $_COR_CURRENT_CONST;
our $_COR_CURRENT_SLOT;
our $_COR_CURRENT_METHOD;

our $COR_RULES;
our $COR_GRAMMAR;

BEGIN {
    $COR_RULES = qr{
        (?(DEFINE)

        # ---------------------------------------
        # SLOTS
        # ---------------------------------------

            (?<PerlSlotIdentifier>
                (?>
                    (\$\!(?&PerlIdentifier))
                    |
                    (\$\.(?&PerlIdentifier))
                    |
                    (\$(?&PerlIdentifier))
                )
            )

            # NOTE:
            # this list might not be complete, it
            # may be missing something valid, or
            # it may be including something we do
            # not want, but it suffices for now.
            # - SL
            (?<PerlSlotDefault>
                (?>
                # heavy lifters ...
                        (?&PerlAnonymousSubroutine)
                    |   (?&PerlDoBlock)
                    |   (?&PerlEvalBlock)
                # calling a perl function ...
                    |   (?>(?&PerlNullaryBuiltinFunction))  (?! (?>(?&PerlOWS)) \( )
                # literal constructors
                    |   (?&PerlAnonymousArray)
                    |   (?&PerlAnonymousHash)
                    |   (?&PerlQuotelikeQR)
                    |   (?&PerlString)
                    |   (?&PerlNumber)
                )
            )

            (?<PerlSlotTypeName>
                (?>
                    ((?&PerlIdentifier)(?&PerlOWS)\[(?&PerlOWS)(?&PerlSlotTypeName)(?&PerlOWS)\])
                    |
                    (?&PerlIdentifier)
                )
            )

            (?<PerlSlotDeclaration>
                (has) (?{
                        $_COR_CURRENT_SLOT = Cor::Parser::ASTBuilder::new_slot_at( pos() - length($^N) )
                    })
                (?&PerlNWS)
                    (
                        ((?&PerlSlotTypeName)) (?{
                            my $pos  = pos();
                            my $name = $^N;
                            $_COR_CURRENT_SLOT->set_type(
                                Cor::Parser::ASTBuilder::new_type_reference( $name, $name, $pos )
                            );
                        })
                        (?&PerlNWS)
                    )?
                    ((?&PerlSlotIdentifier)) (?{ $_COR_CURRENT_SLOT->set_name( $^N ) })
                (?&PerlOWS)
                    (?:
                        (?>
                            ((?&PerlAttributes)) (?{
                                my $pos            = pos();
                                my $attributes_src = $^N;

                                my @attributes = Cor::Parser::ASTBuilder::new_attributes_at(
                                    _parse_attributes( $attributes_src ),
                                    $pos
                                );

                                #use Data::Dumper;
                                #warn Dumper \@attributes;

                                $_COR_CURRENT_SLOT->set_attributes( \@attributes )
                            })
                        )
                        (?&PerlOWS)
                    )?+
                (?>
                    (;) (?{
                        Cor::Parser::ASTBuilder::set_end_location(
                            $_COR_CURRENT_SLOT,
                            pos() - length($^N),
                        );
                    })
                    |
                    (
                        (?&PerlAssignmentOperator)
                        (?&PerlOWS)
                        ((?&PerlSlotDefault)) (?{ $_COR_CURRENT_SLOT->set_default( $^N ) })
                        (;) (?{
                            Cor::Parser::ASTBuilder::set_end_location(
                                $_COR_CURRENT_SLOT,
                                pos() - length($^N),
                            );
                        })
                    )
                    |
                    # TODO:
                    # make this track location information as well
                    (?{
                        die 'unable to parse slot default for `'.$_COR_CURRENT_SLOT->name.'` in class `'.$_COR_CURRENT_META->name.'`';
                    })
                ) (?{ $_COR_CURRENT_META->add_slot( $_COR_CURRENT_SLOT ); })
            )

        # ---------------------------------------
        # METHODS
        # ---------------------------------------

            # NOTE:
            # define this here, not sure if we will use it
            # but good to have it defined differently i think
            # because I think we should restrict the contents
            # of methods to be "strict" by default, and even
            # maybe to not allow certain constructs. This will
            # require recursing down the rulesets, so defining
            # our own PerlMethodStatementSequence to replace
            # the below "PerlStatementSequence" for instance.
            # - SL
            (?<PerlMethodBlock>
                \{  (?>(?&PerlStatementSequence))  \}
            )

            (?<PerlMethodDeclaration>
                (method) (?{
                    $_COR_CURRENT_METHOD = Cor::Parser::ASTBuilder::new_method_at( pos() - length($^N) )
                })
                (?&PerlOWS)
                ((?&PerlQualifiedIdentifier)) (?{ $_COR_CURRENT_METHOD->set_name( $^N ); })
                (?&PerlOWS)
                (?:
                    (?>
                        ((?&PerlAttributes)) (?{

                            my $pos            = pos();
                            my $attributes_src = $^N;

                            my @attributes = Cor::Parser::ASTBuilder::new_attributes_at(
                                _parse_attributes( $attributes_src ),
                                $pos
                            );

                            #use Data::Dumper;
                            #warn Dumper \@attributes;

                            $_COR_CURRENT_METHOD->set_attributes( \@attributes )
                        })
                    )
                    (?&PerlOWS)
                )?+
                (?:
                    (?>
                        ((?&PerlParenthesesList)) (?{

                            my $pos           = pos();
                            my $signature_src = $^N;

                            my $signature = Cor::Parser::ASTBuilder::new_signature_at(
                                _parse_signature( $signature_src ),
                                $pos
                            );

                            #use Data::Dumper;
                            #warn Dumper $signature;

                            $_COR_CURRENT_METHOD->set_signature( $signature );
                        })
                    )
                    (?&PerlOWS)
                )?+
                (?>
                    (\;) (?{
                        $_COR_CURRENT_METHOD->set_is_abstract( 1 );

                        Cor::Parser::ASTBuilder::set_end_location(
                            $_COR_CURRENT_METHOD,
                            pos() - length($^N),
                        );
                    })
                    |
                    ((?&PerlMethodBlock)) (?{

                        my $pos      = pos();
                        my $body_src = $^N;

                        my $body = Cor::Parser::ASTBuilder::new_method_body_at(
                            _parse_method_body(
                                $body_src,
                                $_COR_CURRENT_META
                            ),
                            ($pos - length($body_src)),
                        );

                        $_COR_CURRENT_METHOD->set_body( $body );

                        Cor::Parser::ASTBuilder::set_end_location( $body, $pos );
                        Cor::Parser::ASTBuilder::set_end_location(
                            $_COR_CURRENT_METHOD,
                            pos(), # XXX - need to use use just pos here, not sure why
                        );
                    })
                    |
                    # TODO:
                    # make this track location information as well
                    (?{
                        die 'unable to parse method body for `'.$_COR_CURRENT_METHOD->name.'` in class `'.$_COR_CURRENT_META->name.'`';
                    })
                ) (?{ $_COR_CURRENT_META->add_method( $_COR_CURRENT_METHOD ); })
            )

        # ---------------------------------------
        # CONSTANTS
        # ---------------------------------------

            (?<PerlConstantDeclaration>
                (
                    (const) (?{
                        $_COR_CURRENT_CONST = Cor::Parser::ASTBuilder::new_constant_at(
                            pos() - length($^N)
                        );
                    })
                    (?&PerlNWS)
                    ((?&PerlQualifiedIdentifier)) (?{
                        $_COR_CURRENT_CONST->set_name( $^N );
                    })
                    (?&PerlOWS)
                    (\=)
                    (?&PerlOWS)
                    ((?&PerlExpression)) (?{
                        $_COR_CURRENT_CONST->set_value( $^N );
                    })
                    (?&PerlOWS)
                    (\;) (?{
                        Cor::Parser::ASTBuilder::set_end_location(
                            $_COR_CURRENT_CONST,
                            pos() - length($^N),
                        );

                        $_COR_CURRENT_META->add_constant( $_COR_CURRENT_CONST );
                    })
                )
            )


            (?<PerlModuleDeclaration>
                (
                    (?>
                        module
                        (?&PerlNWS)
                        ((?&PerlQualifiedIdentifier)) (?{
                            my $module_name = $^N;
                            $_COR_CURRENT_MODULE = Cor::Parser::ASTBuilder::new_module_at(
                                pos() - length($module_name)
                            );
                            $_COR_CURRENT_MODULE->set_name( $module_name );
                        })
                        \;
                    )
                )
            )


        # ---------------------------------------
        # CLASS/ROLE
        # ---------------------------------------

            (?<PerlClassRoleBlock> # TODO: come up with a better name
                \{
                    (
                    (?&PerlOWS)
                        ((?:
                            (?>
                                (?&PerlSlotDeclaration)
                                |
                                (?&PerlMethodDeclaration)
                                |
                                (?&PerlConstantDeclaration)
                                |
                                # TODO:
                                # make these track location information as well
                                (?&PerlVariableDeclaration) (?{ die 'my/state/our variables are not allowed inside class/role declarations' })
                                |
                                (?&PerlSubroutineDeclaration) (?{ die 'Subroutines are not allowed inside class/role declarations' })
                                |
                                (?&PerlUseStatement) (?{ die 'use statements are not allowed inside class/role declarations' })
                            )
                            (?&PerlOWS)
                        )*+)
                    (?&PerlOWS)
                    )
                \}
            )

            (?<PerlClassRoleIdentifier>
                ((?&PerlQualifiedIdentifier)) (?{ $_COR_CURRENT_META->set_name( $^N ); })
                (?:
                    (?>(?&PerlNWS)) ((?&PerlVersionNumber)) (?{ $_COR_CURRENT_META->set_version( $^N ); })
                )?+
            )

            (?<PerlClassRoleReference>
                ((?&PerlQualifiedIdentifier)) (?{
                    $_COR_CURRENT_REFERENCE = Cor::Parser::ASTBuilder::new_reference_at( pos() - length($^N) );
                    $_COR_CURRENT_REFERENCE->set_name( $^N );
                })
                (?:
                    (?>(?&PerlNWS)) ((?&PerlVersionNumber)) (?{ $_COR_CURRENT_REFERENCE->set_version( $^N ); })
                )?+
                (?{
                    Cor::Parser::ASTBuilder::set_end_location(
                        $_COR_CURRENT_REFERENCE,
                        pos(), # XXX - need to use use just pos here, not sure why
                    );

                    if ( $_COR_CURRENT_MODULE ) {
                        $_COR_CURRENT_REFERENCE->set_module( $_COR_CURRENT_MODULE );
                    }
                })
            )

            (?<PerlSubclassing>
                (?:
                    isa
                    (?&PerlNWS)
                    (?&PerlClassRoleReference) (?{ $_COR_CURRENT_META->add_superclass( $_COR_CURRENT_REFERENCE ) })
                    (?:
                        (?>\, (?&PerlOWS))
                        (?&PerlClassRoleReference) (?{ $_COR_CURRENT_META->add_superclass( $_COR_CURRENT_REFERENCE ) })
                    )*+
                    (?&PerlOWS)
                )*+
            )

            (?<PerlRoleConsumption>
                (?:
                    does
                    (?&PerlNWS)
                    (?&PerlClassRoleReference) (?{ $_COR_CURRENT_META->add_role( $_COR_CURRENT_REFERENCE ) })
                    (?:
                        (?>\, (?&PerlOWS))
                        (?&PerlClassRoleReference) (?{ $_COR_CURRENT_META->add_role( $_COR_CURRENT_REFERENCE ) })
                    )*+
                    (?&PerlOWS)
                )*+
            )

            (?<PerlClass>
                (
                    (class) (?{
                        $_COR_CURRENT_META = Cor::Parser::ASTBuilder::new_class_at(
                            pos() - length($^N)
                        );
                    })
                    (?&PerlNWS)
                    (?&PerlClassRoleIdentifier)
                    (?&PerlOWS)
                    (?&PerlSubclassing)
                    (?&PerlRoleConsumption)
                    (
                        (?&PerlClassRoleBlock) (?{
                            Cor::Parser::ASTBuilder::set_end_location(
                                $_COR_CURRENT_META,
                                pos()
                            );
                            if ( $_COR_CURRENT_MODULE ) {
                                $_COR_CURRENT_META->set_module( $_COR_CURRENT_MODULE );
                            }
                        })
                    )
                )
            )

            (?<PerlRole>
                (
                    (role) (?{
                        $_COR_CURRENT_META = Cor::Parser::ASTBuilder::new_role_at(
                            pos() - length($^N)
                        );
                    })
                    (?&PerlNWS)
                    (?&PerlClassRoleIdentifier)
                    (?&PerlOWS)
                    (?&PerlRoleConsumption)
                    (
                        (?&PerlClassRoleBlock) (?{
                            Cor::Parser::ASTBuilder::set_end_location(
                                $_COR_CURRENT_META,
                                pos()
                            );
                            if ( $_COR_CURRENT_MODULE ) {
                                $_COR_CURRENT_META->set_module( $_COR_CURRENT_MODULE );
                            }
                        })
                    )
                )
            )

        # ---------------------------------------
        # REDEFINED FROM PPR
        # ---------------------------------------

            (?<PerlVariableScalar>
                    \$\$
                    (?! [\$\{\w] )
                |
                    (?:
                        \$
                        (?:
                            [#]
                            (?=  (?> [\$^\w\{:+] | - (?! > ) )  )
                        )?+
                        (?&PerlOWS)
                    )++
                    (?>
                        \d++
                    |
                        \^ [][A-Z^_?\\]
                    |
                        \{ \^ [A-Z_] \w*+ \}
                    ## << start twigil handling
                        |
                            \! (?&PerlIdentifier) ## twigil with a !
                        |
                            \. (?&PerlIdentifier) ## twigil with a .
                    ## >> end twigil handling
                    |
                        (?>(?&PerlOldQualifiedIdentifier)) (?: :: )?+
                    |
                        :: (?&PerlBlock)
                    |
                        [][!"#\$%&'()*+,.\\/:;<=>?\@\^`|~-]
                    |
                        \{ [!"#\$%&'()*+,.\\/:;<=>?\@\^`|~-] \}
                    |
                        \{ \w++ \}
                    |
                        (?&PerlBlock)
                    )
                |
                    \$\#
            ) # End of rule

        )

        $PPR::GRAMMAR
    }x;

    $COR_GRAMMAR = qr{

        (?:
            ((?&PerlUseStatement)) (?{ push @_COR_USE_STATEMENTS => $^N; })
        )?+

        (?: (?&PerlModuleDeclaration) )?

        (?> (?&PerlRole) | (?&PerlClass) )

        # TODO:
        # - capture complete POD document
        #     - must start with =pod and end with =cut
        #     - store it in package global for latter use
        # - prohibit __END__ tokens (maybe?)
        # - prohibit __DATA__ segements

        $COR_RULES
    }x;
}

sub parse ($source) {

    # localize all the globals ...

    local @_COR_USE_STATEMENTS;
    local $_COR_CURRENT_MODULE;
    local $_COR_CURRENT_META;
    local $_COR_CURRENT_REFERENCE;
    local $_COR_CURRENT_CONST;
    local $_COR_CURRENT_SLOT;
    local $_COR_CURRENT_METHOD;

    my $source_length = length($source);

    my @matches;

    while ( $source =~ /$COR_GRAMMAR/gx ) {

        # TODO: improve error handling here - SL
        if ( $PPR::ERROR ) {
            warn $PPR::ERROR->diagnostics;
        }

        push @matches => $_COR_CURRENT_META;
    }

    my $doc = Cor::Parser::ASTBuilder::new_document(
        use_statements => [ @_COR_USE_STATEMENTS ],
        asts           => [ @matches ],
    );


    Cor::Parser::ASTBuilder::set_end_location(
        $doc,
        $source_length,
    );

    return $doc;
}

# ...

sub _parse_method_body ($source, $meta) {

    # find all the class usage

    my (@class_usage, $class_usage_match, $class_usage_pos);

    # FIXME:
    # this is not ideal, it basically looks for things that
    # perform method calls, if it finds a scalar, then it
    # ignores it, but if it finds a bareword then it will
    # assume that it is some kind of class reference.
    # This can be improved a LOT!
    while ( $source =~ /
            (?>
                (?&PerlVariableScalar)
                |
                ((?&PerlQualifiedIdentifier)) (?{ $class_usage_match = $^N; $class_usage_pos = pos(); })
            )
            (?&PerlOWS)
            (?> \-\>)
            $COR_RULES/gx ) {

        # TODO: improve error handling here - SL
        if ( $PPR::ERROR ) {
            warn $PPR::ERROR->diagnostics;
        }

        next unless $class_usage_match;

        push @class_usage => {
            match => "$class_usage_match",
            start => ($class_usage_pos - length( $class_usage_match ))
        };

        ($class_usage_match, $class_usage_pos) = (undef, undef);
    }

    # find all the method calls on $self

    my (@self_call_matches, $self_call_match, $self_call_pos);

    # FIXME:
    # this is not ideal, it assumes that $self
    # is available, and this may not always be
    # the case, so I think we need to make some
    # kind of other arragements.
    while ( $source =~ /\$self\-\>((?&PerlQualifiedIdentifier)) (?{ $self_call_match = $^N; $self_call_pos = pos(); }) $COR_RULES/gx ) {

        # TODO: improve error handling here - SL
        if ( $PPR::ERROR ) {
            warn $PPR::ERROR->diagnostics;
        }

        # NOTE:
        # doing static analysis on this would not
        # be as easy since there can be method
        # calls from the superclass, so this would
        # require some degree of class MRO traversal
        # in order to determine if the method call
        # is valid. For now we just catch the ones
        # that we know we have as locally defined
        # methods. So in this case we just capture
        # all of them and let the compiler sort it
        # out when generating the code.

        push @self_call_matches => {
            match => "$self_call_match",
            start => ($self_call_pos - length( $self_call_match ))
        };

        ($self_call_match, $self_call_pos) = (undef, undef);
    }

    # find all slot accesses

    my (@slot_matches, $slot_match, $slot_pos);

    while ( $source =~ /((?&PerlVariableScalar)) (?{ $slot_match = $^N; $slot_pos = pos(); }) $COR_RULES/gx ) {

        # TODO: improve error handling here - SL
        if ( $PPR::ERROR ) {
            warn $PPR::ERROR->diagnostics;
        }


        # TODO:
        # this could be used to perform static
        # anaylsis and explode a compile time
        # error if the slot is not defined in
        # the same class
        next unless $meta->has_slot( $slot_match );

        push @slot_matches => {
            match => "$slot_match",
            start => ($slot_pos - length( $slot_match ))
        };

        ($slot_match, $slot_pos) = (undef, undef);
    }

    return ($source, \@slot_matches, \@self_call_matches, \@class_usage);
}

sub _parse_signature ($source) {

    my @matches;

    my $match;
    while ( $source =~ /((?&PerlVariable)) (?{ $match = $^N }) $COR_RULES/gx ) {

        # TODO: improve error handling here - SL
        if ( $PPR::ERROR ) {
            warn $PPR::ERROR->diagnostics;
        }

        push @matches => $match;
    }

    return ($source, \@matches);
}

sub _parse_attributes ($source) {

    my @matches;

    my ($match, $start, $end);
    while ( $source =~
        /
        :
        (?>(?&PerlOWS))
        (?>((?&PerlIdentifier)) (?{
            $match = { name => $^N };
            $start = pos() - length($match->{name});
        }))
        (?:
            (?= \( ) ((?&PPR_quotelike_body)) (?{
                $match->{args} = $^N;
            })
        )?+ (?{ $end = pos(); })

        $COR_RULES/gx
    ) {

        # TODO: improve error handling here - SL
        if ( $PPR::ERROR ) {
            warn $PPR::ERROR->diagnostics;
        }

        if ( $match->{args} ) {
            # clean off the whitespace & parens
            $match->{args} =~ s/^\(\s*//;
            $match->{args} =~ s/\s*\)$//;
        }

        push @matches => {
            match => $match,
            start => $start,
            end   => $end,
        };

        ($match, $start, $end) = (undef, undef, undef);
    }

    return ($source, \@matches);

}

1;

__END__

=pod

=cut

package Cor::Parser;
# ABSTRACT: Parser for the Cor syntax

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

use PPR;

use List::Util;

use Cor::Parser::ASTBuilder;

our @_COR_USE_STATEMENTS;
our $_COR_CURRENT_META;
our $_COR_CURRENT_REFERENCE;
our $_COR_CURRENT_SLOT;
our $_COR_CURRENT_METHOD;

our $COR_RULES;
our $COR_GRAMMAR;

BEGIN {
    $COR_RULES = qr{
        (?(DEFINE)

            (?<PerlSlotIdentifier>
                (?>
                    (\$\!(?&PerlIdentifier))
                    |
                    (\$\.(?&PerlIdentifier))
                    |
                    (\$(?&PerlIdentifier))
                    |
                    (?&PerlIdentifier)
                )
            )

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

            (?<PerlSlotDeclaration>
                (has) (?{
                        $_COR_CURRENT_META->add_slot(
                            $_COR_CURRENT_SLOT = Cor::Parser::ASTBuilder::new_slot_at( pos() - length($^N) )
                        );
                    })
                (?&PerlNWS)
                    (
                        ((?&PerlQualifiedIdentifier)) (?{ $_COR_CURRENT_SLOT->set_type( $^N ) })
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
                )
            )

            (?<PerlMethodDeclaration>
                (method) (?{
                    $_COR_CURRENT_META->add_method(
                        $_COR_CURRENT_METHOD = Cor::Parser::ASTBuilder::new_method_at( pos() - length($^N) )
                    );
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
                        ((?&PerlParenthesesList)) (?{ $_COR_CURRENT_METHOD->set_signature( $^N ) })
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
                )
            )

            # REDEFINE

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

        (
            # Is it a Role or a Class ....
            (?>
                (role)  (?{
                    $_COR_CURRENT_META = Cor::Parser::ASTBuilder::new_role_at( pos() - length($^N) )
                })
                |
                (class) (?{
                    $_COR_CURRENT_META = Cor::Parser::ASTBuilder::new_class_at( pos() - length($^N) )
                })
            )
            (?&PerlNWS)
            # capture the name of the Role/Class
                ((?&PerlQualifiedIdentifier)) (?{ $_COR_CURRENT_META->set_name( $^N ); })
                (?:
                    (?>(?&PerlNWS)) ((?&PerlVersionNumber)) (?{ $_COR_CURRENT_META->set_version( $^N ); })
                )?+
            (?&PerlOWS)
                # if it is a class we can collect superclasses
                (?: isa  (?&PerlNWS)
                    ((?&PerlQualifiedIdentifier)) (?{
                        $_COR_CURRENT_META->add_superclass(
                            $_COR_CURRENT_REFERENCE = Cor::Parser::ASTBuilder::new_reference_at( pos() - length($^N) )
                        );
                        $_COR_CURRENT_REFERENCE->set_name( $^N ); })
                    (?:
                        (?>(?&PerlNWS)) ((?&PerlVersionNumber)) (?{ $_COR_CURRENT_REFERENCE->set_version( $^N ); })
                    )?+
                    (?{
                        Cor::Parser::ASTBuilder::set_end_location(
                            $_COR_CURRENT_REFERENCE,
                            pos(), # XXX - need to use use just pos here, not sure why
                        );
                    })
                    (?&PerlOWS)
                )*+
                # if it is a class/role we can collect consumed roles
                (?: does (?&PerlNWS)
                    ((?&PerlQualifiedIdentifier)) (?{
                        $_COR_CURRENT_META->add_role(
                            $_COR_CURRENT_REFERENCE = Cor::Parser::ASTBuilder::new_reference_at( pos() - length($^N) )
                        );
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
                    })
                    (?&PerlOWS)
                )*+
        ( \{
            (?&PerlOWS)
                ((?:
                    (?>
                        (?&PerlSlotDeclaration)
                        |
                        (?&PerlMethodDeclaration)
                        |
                        (?&PerlVariableDeclaration) (?{ die 'my/state/our variables are not allowed inside class/role declarations' })
                        |
                        (?&PerlSubroutineDeclaration) (?{ die 'Subroutines are not allowed inside class/role declarations' })
                        |
                        (?&PerlUseStatement) (?{ die 'use statements are not allowed inside class/role declarations' })
                    )
                    (?&PerlOWS)
                )*+)
            (?&PerlOWS)
        (\}) (?{
            Cor::Parser::ASTBuilder::set_end_location(
                $_COR_CURRENT_META,
                pos() - length($^N),
            );
        })))

        $COR_RULES
    }x;
}

sub parse ($source) {

    # localize all the globals ...

    local @_COR_USE_STATEMENTS;
    local $_COR_CURRENT_META;
    local $_COR_CURRENT_REFERENCE;
    local $_COR_CURRENT_SLOT;
    local $_COR_CURRENT_METHOD;

    my $source_length = length($source);

    my @matches;

    while ( $source =~ /$COR_GRAMMAR/gx ) {

        # TODO: improve error handling here - SL
        if ( $PPR::ERROR ) {
            warn $PPR::ERROR;
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

    my (@slot_matches, @self_call_matches);

    my ($slot_match, $slot_pos, $self_call_match, $self_call_pos);

    # FIXME:
    # this is not ideal, it assumes that $self
    # is available, and this may not always be
    # the case, so I think we need to make some
    # kind of other arragements.
    while ( $source =~ /\$self\-\>((?&PerlQualifiedIdentifier)) (?{ $self_call_match = $^N; $self_call_pos = pos(); }) $COR_RULES/gx ) {

        # TODO: improve error handling here - SL
        if ( $PPR::ERROR ) {
            warn $PPR::ERROR;
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

    while ( $source =~ /((?&PerlVariableScalar)) (?{ $slot_match = $^N; $slot_pos = pos(); }) $COR_RULES/gx ) {

        # TODO: improve error handling here - SL
        if ( $PPR::ERROR ) {
            warn $PPR::ERROR;
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

    return ($source, \@slot_matches, \@self_call_matches);
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
            warn $PPR::ERROR;
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

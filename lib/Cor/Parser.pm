package Cor::Parser;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

use PPR;

use List::Util;

use Cor::Parser::ASTBuilder;

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
                                ((?&PerlAttributes)) (?{ $_COR_CURRENT_SLOT->set_attributes( $^N ) })
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
                    (?&PerlOWS)
                )*+)
            (?&PerlOWS)
            ((?:
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
                        ((?&PerlAttributes)) (?{ $_COR_CURRENT_METHOD->set_attributes( $^N ) })
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

                        $_COR_CURRENT_METHOD->set_body(
                            Cor::Parser::ASTBuilder::new_method_body_at(
                                _parse_method_body(
                                    $^N,
                                    $_COR_CURRENT_META
                                )
                            )
                        );

                        Cor::Parser::ASTBuilder::set_end_location(
                            $_COR_CURRENT_METHOD,
                            pos(), # XXX - need to use use just pos here, not sure why
                        );
                    })
                )
                (?&PerlOWS)
            )*+)
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

    local $_COR_CURRENT_META = undef;

    my @matches;

    while ( $source =~ /$COR_GRAMMAR/gx ) {

        if ( $PPR::ERROR ) {
            warn $PPR::ERROR;
        }

        push @matches => $_COR_CURRENT_META;
    }

    return ($source, \@matches);
}

# ...

sub _parse_method_body ($source, $meta) {

    my @matches;

    my ($match, $pos);
    while ( $source =~ /((?&PerlVariableScalar)) (?{ $match = $^N; $pos = pos(); }) $COR_RULES/gx ) {

        next unless $meta->has_slot( $match );

        if ( $PPR::ERROR ) {
            warn $PPR::ERROR;
        }

        push @matches => {
            match => "$match",
            start => ($pos - length( $match ))
        };

        ($match, $pos) = (undef, undef);
    }

    return ($source, \@matches);
}

1;

__END__

=pod

=cut

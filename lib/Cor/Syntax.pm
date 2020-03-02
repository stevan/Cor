package Cor::Syntax;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

use PPR;

use Cor::Syntax::ASTBuilder;

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
                    |
                        \! (?&PerlIdentifier) ## << add in the slot handling
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
                (role)  (?{ $_COR_CURRENT_META = Cor::Syntax::ASTBuilder::new_role_at( pos() - length($^N), (1+(substr( $_, 0, $+[0] ) =~ tr/\n//)) ) })
                |
                (class) (?{ $_COR_CURRENT_META = Cor::Syntax::ASTBuilder::new_class_at( pos() - length($^N), (1+(substr( $_, 0, $+[0] ) =~ tr/\n//)) ) })
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
                        $_COR_CURRENT_META->add_superclass( $_COR_CURRENT_REFERENCE = Cor::Syntax::ASTBuilder::new_reference_at( pos() - length($^N), (1+(substr( $_, 0, $+[0] ) =~ tr/\n//)) ) ); $_COR_CURRENT_REFERENCE->set_name( $^N ); })
                    (?:
                        (?>(?&PerlNWS)) ((?&PerlVersionNumber)) (?{ $_COR_CURRENT_REFERENCE->set_version( $^N ); })
                    )?+
                    (?{
                        $_COR_CURRENT_REFERENCE->set_end_location(
                            Cor::Syntax::AST::Location->new(
                                char_number => pos(), # XXX - need to use use just pos here, not sure why
                                line_number => (1+(substr( $_, 0, $+[0] ) =~ tr/\n//))
                            )
                        );
                    })
                    (?&PerlOWS)
                )*+
                # if it is a class/role we can collect consumed roles
                (?: does (?&PerlNWS)
                    ((?&PerlQualifiedIdentifier)) (?{ $_COR_CURRENT_META->add_role( $_COR_CURRENT_REFERENCE = Cor::Syntax::ASTBuilder::new_reference_at( pos() - length($^N), (1+(substr( $_, 0, $+[0] ) =~ tr/\n//)) ) ); $_COR_CURRENT_REFERENCE->set_name( $^N ); })
                    (?:
                        (?>(?&PerlNWS)) ((?&PerlVersionNumber)) (?{ $_COR_CURRENT_REFERENCE->set_version( $^N ); })
                    )?+
                    (?{
                        $_COR_CURRENT_REFERENCE->set_end_location(
                            Cor::Syntax::AST::Location->new(
                                char_number => pos(), # XXX - need to use use just pos here, not sure why
                                line_number => (1+(substr( $_, 0, $+[0] ) =~ tr/\n//))
                            )
                        );
                    })
                    (?&PerlOWS)
                )*+
        ( \{
            (?&PerlOWS)
                ((?:
                    (has) (?{ $_COR_CURRENT_META->add_slot( $_COR_CURRENT_SLOT = Cor::Syntax::ASTBuilder::new_slot_at( pos() - length($^N), (1+(substr( $_, 0, $+[0] ) =~ tr/\n//)) ) ); })
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
                            $_COR_CURRENT_SLOT->set_end_location(
                                Cor::Syntax::AST::Location->new(
                                    char_number => pos() - length($^N),
                                    line_number => (1+(substr( $_, 0, $+[0] ) =~ tr/\n//))
                                )
                            );
                        })
                        |
                        (
                            (?&PerlAssignmentOperator)
                            (?&PerlOWS)
                            ((?&PerlSlotDefault)) (?{ $_COR_CURRENT_SLOT->set_default( $^N ) })
                            (;) (?{
                                $_COR_CURRENT_SLOT->set_end_location(
                                    Cor::Syntax::AST::Location->new(
                                        char_number => pos() - length($^N),
                                        line_number => (1+(substr( $_, 0, $+[0] ) =~ tr/\n//))
                                    )
                                );
                            })
                        )
                    )
                    (?&PerlOWS)
                )*+)
            (?&PerlOWS)
            ((?:
                (method) (?{ $_COR_CURRENT_META->add_method( $_COR_CURRENT_METHOD = Cor::Syntax::ASTBuilder::new_method_at( pos() - length($^N), (1+(substr( $_, 0, $+[0] ) =~ tr/\n//)) ) ); })
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
                        $_COR_CURRENT_METHOD->set_end_location(
                            Cor::Syntax::AST::Location->new(
                                char_number => pos() - length($^N),
                                line_number => (1+(substr( $_, 0, $+[0] ) =~ tr/\n//))
                            )
                        );
                    })
                    |
                    ((?&PerlBlock)) (?{
                        $_COR_CURRENT_METHOD->set_body( $^N );
                        $_COR_CURRENT_METHOD->set_end_location(
                            Cor::Syntax::AST::Location->new(
                                char_number => pos(), # XXX - need to use use just pos here, not sure why
                                line_number => (1+(substr( $_, 0, $+[0] ) =~ tr/\n//))
                            )
                        );
                    })
                )
                (?&PerlOWS)
            )*+)
        (\}) (?{
            $_COR_CURRENT_META->set_end_location(
                Cor::Syntax::AST::Location->new(
                    char_number => pos() - length($^N),
                    line_number => (1+(substr( $_, 0, $+[0] ) =~ tr/\n//))
                )
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

    return @matches;

}

# NOTE:
# We need to do this kind of thing at some point
# so we can check the slot usage, but this is just
# a primative example. A real implementation will
# need to take a list of valid slot names so that
# it can ignore normal lexicals. Or perhaps not,
# and that filtering can be done else where, either
# way this will need to construct a more complex
# AST object with location information, etc.
# - SL
# sub _extract_all_variable_access_from_method_body ($source) {
#
#     my @matches;
#
#     while ( $source =~ /((?&PerlVariableScalar)) $COR_RULES/gx ) {
#
#         if ( $PPR::ERROR ) {
#             warn $PPR::ERROR;
#         }
#
#         push @matches => $1;
#     }
#
#     return @matches;
# }

1;

__END__

=pod

=cut

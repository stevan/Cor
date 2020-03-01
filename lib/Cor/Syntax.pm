package Cor::Syntax;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

use PPR;

use Cor::Builder;

our $COR_CURRENT_META;
our $COR_CURRENT_REFERENCE;
our $COR_CURRENT_SLOT;   # TODO
our $COR_CURRENT_METHOD; # TODO

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
                role  (?{ $COR_CURRENT_META = Cor::Builder::Role->new; })
                |
                class (?{ $COR_CURRENT_META = Cor::Builder::Class->new; })
            )
            (?&PerlNWS)
            # capture the name of the Role/Class
                ((?&PerlQualifiedIdentifier)) (?{ $COR_CURRENT_META->set_name( $^N ); })
                (?:
                    (?>(?&PerlNWS)) ((?&PerlVersionNumber)) (?{ $COR_CURRENT_META->set_version( $^N ); })
                )?+
            (?&PerlOWS)
                # if it is a class we can collect superclasses
                (?: isa  (?&PerlNWS)
                    ((?&PerlQualifiedIdentifier)) (?{
                        $COR_CURRENT_META->add_superclass( $COR_CURRENT_REFERENCE = Cor::Builder::Reference->new( name => $^N ) ); })
                    (?:
                        (?>(?&PerlNWS)) ((?&PerlVersionNumber)) (?{ $COR_CURRENT_REFERENCE->set_version( $^N ); })
                    )?+
                    (?&PerlOWS)
                )*+
                # if it is a class/role we can collect consumed roles
                (?: does (?&PerlNWS)
                    ((?&PerlQualifiedIdentifier)) (?{ $COR_CURRENT_META->add_role( $COR_CURRENT_REFERENCE = Cor::Builder::Reference->new( name => $^N ) ); })
                    (?:
                        (?>(?&PerlNWS)) ((?&PerlVersionNumber)) (?{ $COR_CURRENT_REFERENCE->set_version( $^N ); })
                    )?+
                    (?&PerlOWS)
                )*+
        ( \{
            (?&PerlOWS)
                ((?:
                    (has) (?{ $COR_CURRENT_META->add_slot( $COR_CURRENT_SLOT = Cor::Builder::Slot->new ); })
                    (?&PerlNWS)
                        (
                            ((?&PerlQualifiedIdentifier)) (?{ $COR_CURRENT_SLOT->set_type( $^N ) })
                            (?&PerlNWS)
                        )?
                        ((?&PerlSlotIdentifier)) (?{ $COR_CURRENT_SLOT->set_name( $^N ) })
                    (?&PerlOWS)
                        (?:
                            (?>
                                ((?&PerlAttributes)) (?{ $COR_CURRENT_SLOT->set_attributes( $^N ) })
                            )
                            (?&PerlOWS)
                        )?+
                    (?>
                        ;
                        |
                        (
                            (?&PerlAssignmentOperator)
                            (?&PerlOWS)
                            ((?&PerlSlotDefault)) (?{ $COR_CURRENT_SLOT->set_default( $^N ) })
                            ;
                        )
                    )
                    (?&PerlOWS)
                )*+)
            (?&PerlOWS)
            ((?:
                (method) (?{ $COR_CURRENT_META->add_method( $COR_CURRENT_METHOD = Cor::Builder::Method->new ); })
                (?&PerlOWS)
                ((?&PerlQualifiedIdentifier)) (?{ $COR_CURRENT_METHOD->set_name( $^N ); })
                (?&PerlOWS)
                (?:
                    (?>
                        ((?&PerlAttributes)) (?{ $COR_CURRENT_METHOD->set_attributes( $^N ) })
                    )
                    (?&PerlOWS)
                )?+
                (?:
                    (?>
                        ((?&PerlParenthesesList)) (?{ $COR_CURRENT_METHOD->set_signature( $^N ) })
                    )
                    (?&PerlOWS)
                )?+
                (?>
                    (\;) (?{ $COR_CURRENT_METHOD->is_abstract( 1 ) })
                    |
                    ((?&PerlBlock)) (?{ $COR_CURRENT_METHOD->set_body( $^N ) })
                )
                (?&PerlOWS)
            )*+)
        \} ))

        $COR_RULES
    }x;
}

sub rules   { $COR_RULES   }
sub grammar { $COR_GRAMMAR }

sub parse ($source) {

    local $COR_CURRENT_META = undef;

    my @matches;

    while ( $source =~ /$COR_GRAMMAR/gx ) {

        if ( $PPR::ERROR ) {
            warn $PPR::ERROR;
        }

        push @matches => $COR_CURRENT_META;
    }

    return @matches;

}

1;

__END__

=pod

=cut

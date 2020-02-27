package Cor::Syntax;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

use PPR;

use Cor::Static;

our $COR_CURRENT_META;
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
                role  (?{ $COR_CURRENT_META = Cor::Static::Role->new; })
                |
                class (?{ $COR_CURRENT_META = Cor::Static::Class->new; })
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
                    ((?&PerlQualifiedIdentifier)) (?{ $COR_CURRENT_META->add_superclass({ name => $^N }); })
                    (?:
                        (?>(?&PerlNWS)) ((?&PerlVersionNumber)) (?{ $COR_CURRENT_META->{superclasses}->[-1]->{version} = $^N; })
                    )?+
                    (?&PerlOWS)
                )*+
                # if it is a class/role we can collect consumed roles
                (?: does (?&PerlNWS)
                    ((?&PerlQualifiedIdentifier)) (?{ $COR_CURRENT_META->add_role({ name => $^N }); })
                    (?:
                        (?>(?&PerlNWS)) ((?&PerlVersionNumber)) (?{ $COR_CURRENT_META->{roles}->[-1]->{version} = $^N; })
                    )?+
                    (?&PerlOWS)
                )*+
        ( \{
            (?&PerlOWS)
                ((?:
                    (has) (?{ $COR_CURRENT_META->add_slot({}); })
                    (?&PerlNWS)
                        (
                            ((?&PerlQualifiedIdentifier)) (?{ $COR_CURRENT_META->{slots}->[-1]->{type} = $^N })
                            (?&PerlNWS)
                        )?
                        ((?&PerlSlotIdentifier)) (?{ $COR_CURRENT_META->{slots}->[-1]->{name} = $^N })
                    (?&PerlOWS)
                        (?:
                            (?>
                                ((?&PerlAttributes)) (?{ $COR_CURRENT_META->{slots}->[-1]->{attributes} = $^N })
                            )
                            (?&PerlOWS)
                        )?+
                    (?>
                        ;
                        |
                        (
                            (?&PerlAssignmentOperator)
                            (?&PerlOWS)
                            ((?&PerlSlotDefault)) (?{ $COR_CURRENT_META->{slots}->[-1]->{default} = $^N })
                            ;
                        )
                    )
                    (?&PerlOWS)
                )*+)
            (?&PerlOWS)
            ((?:
                (method) (?{ $COR_CURRENT_META->add_method({}); })
                (?&PerlOWS)
                ((?&PerlQualifiedIdentifier)) (?{ $COR_CURRENT_META->{methods}->[-1]->{name} = $^N; })
                (?&PerlOWS)
                (?:
                    (?>
                        ((?&PerlAttributes)) (?{ $COR_CURRENT_META->{methods}->[-1]->{attributes} = $^N })
                    )
                    (?&PerlOWS)
                )?+
                (?:
                    (?>
                        ((?&PerlParenthesesList)) (?{ $COR_CURRENT_META->{methods}->[-1]->{signature} = $^N })
                    )
                    (?&PerlOWS)
                )?+
                (?>
                    (\;) (?{ $COR_CURRENT_META->{methods}->[-1]->{is_required} = 1 })
                    |
                    ((?&PerlBlock)) (?{ $COR_CURRENT_META->{methods}->[-1]->{body} = $^N })
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

        push @matches => { %$COR_CURRENT_META };
    }

    return @matches;

}

1;

__END__

=pod

=cut

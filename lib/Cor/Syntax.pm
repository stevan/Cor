package Cor::Syntax;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

use PPR;

use List::Util;

use Cor::Syntax::ASTBuilder;

# HACK FOR NOW
our $_ENABLE_VARIABLE_SUBSTITUTION_IN_METHOD_BODY = 0;

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
            # maybe to not allow certain constructs.
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
                    |
                        \! (?&PerlIdentifier) ## << add in the twigil handling, currently just C<$!foo>
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
                    ((?&PerlMethodBlock)) (?{
                        $_COR_CURRENT_METHOD->set_body(
                            $_ENABLE_VARIABLE_SUBSTITUTION_IN_METHOD_BODY
                            ? (_extract_all_variable_access_from_method_body( $^N, $_COR_CURRENT_META ))
                            : $^N
                        );
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

sub _extract_all_variable_access_from_method_body ($source, $meta) {

    my %valid_slots = map { $_->name => undef } $meta->slots->@*;

    #warn Data::Dumper::Dumper( \%valid_slots );

    my @matches;

    my ($match, $pos);
    while ( $source =~ /((?&PerlVariableScalar)) (?{ $match = $^N; $pos = pos(); }) $COR_RULES/gx ) {

        next unless exists $valid_slots{ $match };

        if ( $PPR::ERROR ) {
            warn $PPR::ERROR;
        }

        push @matches => {
            match => "$match",
            start => ($pos - length( $match ))
        };

        ($match, $pos) = (undef, undef);
    }

    my $source_length = length( $source );

    my $offset = 0;
    foreach my $m ( @matches ) {
        my $patch = '$_[0]->{q[' . $m->{match} . ']}';

        #use Data::Dumper;
        #warn Dumper [ $m, [
        #    $source,
        #    $source_length,
        #    $m->{start} + $offset,
        #    length( $m->{match} )
        #    ] ];

        substr(
            $source,
            $m->{start} + $offset,
            length( $m->{match} ),
        ) = $patch;
        $offset = length( $patch ) - length( $m->{match} );
    }

    return $source;
}

1;

__END__

=pod

=cut

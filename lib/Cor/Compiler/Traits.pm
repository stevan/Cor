package Cor::Compiler::Traits;
# ABSTRACT: The set of core traits for Cor

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

our %TRAITS;
BEGIN {

    %TRAITS = (
        'reader' => sub ( $meta, $item, $attribute ) {

            my ($method, $slot_name);
            if ( $item->isa('Cor::Parser::AST::Method') ) {
                $method = $item;
                # it is no longer abstract ...
                $method->set_is_abstract(0);
                # we expect the slot name to be passed ...
                $slot_name = $attribute->args;
            }
            elsif ( $item->isa('Cor::Parser::AST::Slot') ) {
                # create a method ...
                $method = Cor::Parser::ASTBuilder::new_method_at( -1 );

                # give it a name
                my $name = $attribute->has_args
                    ? $attribute->args
                    : $item->name;
                # make sure to strip off sigil
                $name =~ s/^\$//;
                $method->set_name( $name );

                # now set the slot name ...
                $slot_name = $item->name;

                # make sure to add method to the class
                $meta->add_method( $method );
            }
            else {
                die "WTF! $item";
            }

            $method->set_signature('($)');
            $method->set_body(
                Cor::Parser::ASTBuilder::new_method_body_at(
                    '{ $_[0]->{q['.$slot_name.']} }',
                    [],
                    -1
                )
            );
            return 1;
        },
        'writer' => sub ( $meta, $item, $attribute ) {

            my ($method, $slot_name);
            if ( $item->isa('Cor::Parser::AST::Method') ) {
                $method = $item;
                # it is no longer abstract ...
                $method->set_is_abstract(0);
                # we expect the slot name to be passed ...
                $slot_name = $attribute->args;
            }
            elsif ( $item->isa('Cor::Parser::AST::Slot') ) {
                # create a method ...
                $method = Cor::Parser::ASTBuilder::new_method_at( -1 );

                # give it a name
                my $name = $attribute->has_args
                    ? $attribute->args
                    : $item->name;
                # make sure to strip off sigil
                $name =~ s/^\$//;
                $method->set_name( $name );

                # now set the slot name ...
                $slot_name = $item->name;

                # make sure to add method to the class
                $meta->add_method( $method );
            }
            else {
                die "WTF! $item";
            }

            $method->set_is_abstract(0);
            $method->set_signature('($, $)');
            $method->set_body(
                Cor::Parser::ASTBuilder::new_method_body_at(
                    '{ $_[0]->{q['.$attribute->args.']} = $_[1] }',
                    [],
                    -1
                )
            );
            return 1;
        },
    );

    # simple aliases
    $TRAITS{ro} = $TRAITS{reader};
    $TRAITS{wo} = $TRAITS{writer};
}

1;

__END__

=pod

=cut

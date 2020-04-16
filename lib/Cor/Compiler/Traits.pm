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
                    : $item->identifier;
                $method->set_name( $name );

                # now set the slot name ...
                $slot_name = $item->name;

                # make sure to add method to the class
                $meta->add_method( $method );
            }
            else {
                die "WTF! $item";
            }

            $method->set_signature(
                Cor::Parser::ASTBuilder::create_method_signature( [ '$self' ] )
            );
            $method->set_body(
                Cor::Parser::ASTBuilder::create_method_body(
                    '{ $self->{q['.$slot_name.']} }',
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
                    : $item->identifier;
                $method->set_name( $name );

                # now set the slot name ...
                $slot_name = $item->name;

                # make sure to add method to the class
                $meta->add_method( $method );
            }
            else {
                die "WTF! $item";
            }

            $method->set_signature(
                Cor::Parser::ASTBuilder::create_method_signature( [ '$self', '$arg' ] )
            );
            $method->set_body(
                Cor::Parser::ASTBuilder::create_method_body(
                    '{ $self->{q['.$slot_name.']} = $arg }',
                )
            );
            return 1;
        },
        'accessor' => sub ( $meta, $item, $attribute ) {

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
                    : $item->identifier;
                $method->set_name( $name );

                # now set the slot name ...
                $slot_name = $item->name;

                # make sure to add method to the class
                $meta->add_method( $method );
            }
            else {
                die "WTF! $item";
            }

            $method->set_signature(
                Cor::Parser::ASTBuilder::create_method_signature( [ '$self', '@args' ] )
            );
            $method->set_body(
                Cor::Parser::ASTBuilder::create_method_body(
                    '{ $self->{q['.$slot_name.']} = $args[0] if @args; $self->{q['.$slot_name.']}; }',
                )
            );
            return 1;
        },
        'predicate' => sub ( $meta, $item, $attribute ) {

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
                my $name;
                if ($attribute->has_args) {
                    $name = $attribute->args;
                }
                else {
                    $name = $item->identifier;
                    $name = 'has_' . $name;
                }
                $method->set_name( $name );

                # now set the slot name ...
                $slot_name = $item->name;

                # make sure to add method to the class
                $meta->add_method( $method );
            }
            else {
                die "WTF! $item";
            }

            $method->set_signature(
                Cor::Parser::ASTBuilder::create_method_signature( [ '$self' ] )
            );
            $method->set_body(
                Cor::Parser::ASTBuilder::create_method_body(
                    '{ defined $self->{q['.$slot_name.']} }',
                )
            );
            return 1;
        },
    );

    # simple aliases
    $TRAITS{ro} = $TRAITS{reader};
    $TRAITS{rw} = $TRAITS{accessor};
    $TRAITS{wo} = $TRAITS{writer};
}

1;

__END__

=pod

=cut

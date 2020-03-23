package Cor::Compiler::Traits;
# ABSTRACT: The set of core traits for Cor

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

our %TRAITS = (
    'ro' => sub ( $meta, $method, $attribute ) {
        return unless $method->isa('Cor::Parser::AST::Method');
        return unless $method->has_attributes;

        $method->set_is_abstract(0);
        $method->set_attributes([ grep $_ ne $attribute, $method->attributes->@* ]);
        $method->set_body(
            Cor::Parser::ASTBuilder::new_method_body_at(
                '{ $_[0]->{q['.$attribute->args.']} }',
                [],
                -1
            )
        );
    },
);

1;

__END__

=pod

=cut

package Cor::Compiler::Unit;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use Cor::Compiler::Unit::Role;
use Cor::Compiler::Unit::Class;

use parent 'UNIVERSAL::Object';

use slots (
    asts => sub {},
);

sub generate_source ($self) {

    my @units = map {
        $_->isa('Cor::Parser::AST::Class')
            ? Cor::Compiler::Unit::Class->new( ast => $_ )
            : Cor::Compiler::Unit::Role->new( ast => $_ )
    } $self->{asts}->@*;

    my @compiled = map {
        $_->generate_source
    } @units;

    return join "\n" => @compiled;
}

1;

__END__

=pod

=cut

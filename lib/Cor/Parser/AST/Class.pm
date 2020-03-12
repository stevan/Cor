package Cor::Parser::AST::Class;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use parent 'Cor::Parser::AST::Role';

use slots (
    superclasses => sub { [] },
);

sub superclasses : ro;

sub add_superclass ($self, $superclass) {
    # TODO - test that $superclass is a Builder::Reference
    push $self->{superclasses}->@* => $superclass;
}

sub has_superclasses ($self) { !! $self->{superclasses}->@* }

sub has_superclass ($self, $name) { !! scalar grep $_->name eq $name, $self->{methods}->@* }

1;

__END__

=pod

=cut

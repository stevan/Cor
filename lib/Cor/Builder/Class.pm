package Cor::Builder::Class;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use parent 'Cor::Builder::Role';

use slots (
    superclasses => sub { [] },
);

sub superclasses : ro;

sub add_superclass ($self, $superclass) {
    # TODO - test that $superclass is a Builder::Reference
    push $self->{superclasses}->@* => $superclass;
}

sub has_superclasses ($self) { !! $self->{superclasses}->@* }

1;

__END__

=pod

=cut

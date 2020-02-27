package Cor::Static::Class;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

use parent 'Cor::Static::Role';

use slots (
    superclasses => sub { [] },
);

sub add_superclass ($self, $superclass) {
    push $self->{superclasses}->@* => $superclass;
}

1;

__END__

=pod

=cut

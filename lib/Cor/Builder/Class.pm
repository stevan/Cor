package Cor::Builder::Class;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

use parent 'Cor::Builder::Role';

use slots (
    superclasses => sub { [] },
);

sub add_superclass ($self, $superclass) {
    # TODO - test that $superclass is a Builder::Reference
    push $self->{superclasses}->@* => $superclass;
}

1;

__END__

=pod

=cut

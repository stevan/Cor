package Cor::Builder::Role;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use parent 'UNIVERSAL::Object';
use roles  'Cor::Builder::Role::Dumpable';

use slots (
    name    => sub { undef },
    version => sub { undef },
    roles   => sub { []    },
    slots   => sub { []    },
    methods => sub { []    },
);

sub set_name    : wo(name);
sub set_version : wo(version);

sub add_role ($self, $role) {
    # TODO - test that $role is a Builder::Reference
    push $self->{roles}->@* => $role;
}

sub add_slot ($self, $slot) {
    # TODO - test that $slot is a Builder::Slot
    push $self->{slots}->@* => $slot;
}

sub add_method ($self, $method) {
    # TODO - test that $method is a Builder::Method
    push $self->{methods}->@* => $method;
}


1;

__END__

=pod

=cut

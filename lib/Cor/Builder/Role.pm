package Cor::Builder::Role;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

use parent 'UNIVERSAL::Object';
use roles  'Cor::Builder::Role::Dumpable';

use slots (
    name    => sub { undef },
    version => sub { undef },
    roles   => sub { []    },
    slots   => sub { []    },
    methods => sub { []    },
);

sub set_name ($self, $name) {
    $self->{name} = $name;
}

sub set_version ($self, $version) {
    $self->{version} = $version;
}

sub add_role ($self, $role) {
    push $self->{roles}->@* => $role;
}

sub add_slot ($self, $slot) {
    push $self->{slots}->@* => $slot;
}

sub add_method ($self, $method) {
    push $self->{methods}->@* => $method;
}


1;

__END__

=pod

=cut

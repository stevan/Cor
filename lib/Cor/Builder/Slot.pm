package Cor::Builder::Slot;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

use parent 'UNIVERSAL::Object';
use roles  'Cor::Builder::Role::Dumpable';

use slots (
    name       => sub {},
    type       => sub {},
    attributes => sub {},
    default    => sub {},
);

sub set_name ($self, $name) {
    $self->{name} = $name;
}

sub set_type ($self, $type) {
    $self->{type} = $type;
}

sub set_attributes ($self, $attributes) {
    $self->{attributes} = $attributes;
}

sub set_default ($self, $default) {
    $self->{default} = $default;
}

1;

__END__

=pod

=cut

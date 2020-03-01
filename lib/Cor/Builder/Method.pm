package Cor::Builder::Method;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

use parent 'UNIVERSAL::Object';
use roles  'Cor::Builder::Role::Dumpable';

use slots (
    name        => sub {},
    attributes  => sub {},
    signature   => sub {},
    body        => sub {},
    is_abstract => sub {},
);

sub set_name ($self, $name) {
    $self->{name} = $name;
}

sub set_attributes ($self, $attributes) {
    $self->{attributes} = $attributes;
}

sub set_signature ($self, $signature) {
    $self->{signature} = $signature;
}

sub set_body ($self, $body) {
    $self->{body} = $body;
}

sub is_abstract ($self, $is_abstract) {
    $self->{is_abstract} = $is_abstract;
}

# alias
*set_is_abstract = \&is_abstract;

1;

__END__

=pod

=cut

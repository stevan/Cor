package Cor::Builder::Reference;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

use parent 'UNIVERSAL::Object';
use roles  'Cor::Builder::Role::Dumpable';

use slots (
    name => sub {},
);

sub set_name ($self, $name) {
    $self->{name} = $name;
}

sub set_version ($self, $version) {
    $self->{version} = $version;
}

1;

__END__

=pod

=cut

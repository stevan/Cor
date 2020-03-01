package Cor::Builder::Slot;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use parent 'UNIVERSAL::Object';
use roles  'Cor::Builder::Role::Dumpable';

use slots (
    name       => sub {},
    type       => sub {},
    attributes => sub {},
    default    => sub {},
);

sub set_name       : wo(name);
sub set_type       : wo(type);
sub set_attributes : wo(attributes);
sub set_default    : wo(default);

1;

__END__

=pod

=cut

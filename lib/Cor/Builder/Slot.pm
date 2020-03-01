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

sub name       : ro;
sub type       : ro;
sub attributes : ro;
sub default    : ro;

sub set_name       : wo;
sub set_type       : wo;
sub set_attributes : wo;
sub set_default    : wo;

sub has_name       : predicate;
sub has_type       : predicate;
sub has_attributes : predicate;
sub has_default    : predicate;

1;

__END__

=pod

=cut

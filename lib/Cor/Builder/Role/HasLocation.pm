package Cor::Builder::Role::HasLocation;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use slots (
    location => sub {}
);

sub location     : ro;
sub set_location : wo;
sub has_location : predicate;

1;

__END__

=pod

=cut

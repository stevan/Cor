package Cor::Builder::Location;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use parent 'UNIVERSAL::Object::Immutable';

use slots (
    start => sub { die 'The `start` postion is required' },
);

sub start : ro;

1;

__END__

=pod

=cut

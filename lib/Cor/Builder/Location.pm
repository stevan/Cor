package Cor::Builder::Location;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use parent 'UNIVERSAL::Object::Immutable';

use slots (
    pos    => sub { die 'The `pos` is required'    },
    length => sub { die 'The `length` is required' },
);

sub pos    : ro;
sub length : ro;

sub start ($self) { $self->{pos} - $self->{length} }
sub end   ($self) { $self->{pos} }


1;

__END__

=pod

=cut

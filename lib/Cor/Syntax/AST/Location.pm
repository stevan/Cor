package Cor::Syntax::AST::Location;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use parent 'UNIVERSAL::Object::Immutable';

use slots (
    line_number => sub { die 'A `line_number` is required' },
    char_number => sub { die 'A `char_number` is required' },
);

sub line_number : ro;
sub char_number : ro;

1;

__END__

=pod

=cut

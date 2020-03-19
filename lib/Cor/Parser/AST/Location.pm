package Cor::Parser::AST::Location;
# ABSTRACT: Cor AST source locations

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use parent 'UNIVERSAL::Object::Immutable';

use slots (
    char_at => sub { die 'A `char_at` is required' },
);

sub char_at : ro;

1;

__END__

=pod

=cut

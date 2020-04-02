package Cor::Parser::AST::Role::HasLocation;
# ABSTRACT: Cor AST for AST entity which has a location

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];


use slots (
    start_location => sub {},
    end_location   => sub {},
);

sub start_location     : ro;
sub end_location       : ro;

sub set_start_location : wo;
sub set_end_location   : wo;

sub has_start_location : predicate;
sub has_end_location   : predicate;

1;

__END__

=pod

=cut

package Cor::Parser::AST::Attribute;
# ABSTRACT: Cor AST for attributes attached to slots of methods

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use parent 'Cor::Parser::AST::Base';

use slots (
    name => sub {},
    args => sub {},
);

sub name : ro;
sub args : ro;

sub set_name : wo;
sub set_args : wo;

sub has_name : predicate;
sub has_args : predicate;

1;

__END__

=pod

=cut

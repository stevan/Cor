package Cor::Parser::AST::Constant;
# ABSTRACT: Cor AST for constant declarations

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use parent 'UNIVERSAL::Object';
use roles  'Cor::Parser::AST::Role::HasLocation';

use slots (
    name  => sub {},
    value => sub {},
);

sub name  : ro;
sub value : ro;

sub set_name  : wo;
sub set_value : wo;

sub has_name  : predicate;
sub has_value : predicate;

1;

__END__

=pod

=cut

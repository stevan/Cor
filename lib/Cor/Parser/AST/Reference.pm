package Cor::Parser::AST::Reference;
# ABSTRACT: Cor AST for referenced packages

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use parent 'Cor::Parser::AST::Base';

use slots (
    name    => sub {},
    version => sub {},
);

sub name    : ro;
sub version : ro;

sub set_name    : wo;
sub set_version : wo;

sub has_name    : predicate;
sub has_version : predicate;

1;

__END__

=pod

=cut

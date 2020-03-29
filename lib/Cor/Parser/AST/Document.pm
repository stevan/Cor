package Cor::Parser::AST::Document;
# ABSTRACT: Cor AST for an entire document

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use parent 'Cor::Parser::AST::Base';

use slots (
    use_statements => sub { +[] },
    asts           => sub { +[] },
);

sub use_statements : ro;
sub asts           : ro;

sub set_use_statements : wo;
sub set_asts           : wo;

sub has_use_statements : predicate;
sub has_asts           : predicate;

1;

__END__

=pod

=cut

package Cor::Parser::AST::Method::Signature;
# ABSTRACT: Cor AST for method signatures

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use parent 'UNIVERSAL::Object';
use roles  'Cor::Parser::AST::Role::HasLocation';

use slots (
    arguments => sub { [] }
);

sub     arguments : ro;
sub set_arguments : wo;
sub has_arguments : predicate;

1;

__END__

=pod

=cut

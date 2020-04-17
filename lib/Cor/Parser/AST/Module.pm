package Cor::Parser::AST::Module;
# ABSTRACT: Cor AST for module declarations

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use List::Util;

use parent 'UNIVERSAL::Object';
use roles  'Cor::Parser::AST::Role::HasLocation';

use slots (
    name => sub {},
);

sub name     : ro;
sub set_name : wo;
sub has_name : predicate;

1;

__END__

=pod

=cut

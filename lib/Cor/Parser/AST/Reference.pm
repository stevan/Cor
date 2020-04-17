package Cor::Parser::AST::Reference;
# ABSTRACT: Cor AST for referenced packages

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use parent 'UNIVERSAL::Object';
use roles  'Cor::Parser::AST::Role::HasLocation';

use slots (
    name    => sub {},
    version => sub {},
    # internal
    _module  => sub {},
);

sub name    : ro;
sub version : ro;
sub module  : ro(_);

sub set_name    : wo;
sub set_version : wo;
sub set_module  : wo(_);

sub has_name    : predicate;
sub has_version : predicate;
sub has_module  : predicate(_);

1;

__END__

=pod

=cut

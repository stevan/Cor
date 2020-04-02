package Cor::Parser::AST::Slot;
# ABSTRACT: Cor AST for slot declarations

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use parent 'UNIVERSAL::Object';
use roles  'Cor::Parser::AST::Role::HasLocation',
           'Cor::Parser::AST::Role::HasAttributes';

use slots (
    name       => sub {},
    type       => sub {},
    default    => sub {},
);

sub name       : ro;
sub type       : ro;
sub default    : ro;

sub set_name       : wo;
sub set_type       : wo;
sub set_default    : wo;

sub has_name       : predicate;
sub has_type       : predicate;
sub has_default    : predicate;

1;

__END__

=pod

=cut

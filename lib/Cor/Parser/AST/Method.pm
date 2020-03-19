package Cor::Parser::AST::Method;
# ABSTRACT: Cor AST for method declarations

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use parent 'Cor::Parser::AST::Base';

use slots (
    name        => sub {},
    attributes  => sub {},
    signature   => sub {},
    body        => sub {},
    is_abstract => sub {},
);

sub name        : ro;
sub attributes  : ro;
sub signature   : ro;
sub body        : ro;
sub is_abstract : ro;

sub set_name        : wo;
sub set_attributes  : wo;
sub set_signature   : wo;
sub set_body        : wo;
sub set_is_abstract : wo;

sub has_name        : predicate;
sub has_attributes  : predicate;
sub has_signature   : predicate;
sub has_body        : predicate;
sub has_is_abstract : predicate;

1;

__END__

=pod

=cut

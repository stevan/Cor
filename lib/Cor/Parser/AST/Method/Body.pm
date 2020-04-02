package Cor::Parser::AST::Method::Body;
# ABSTRACT: Cor AST for method body definitons

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use parent 'UNIVERSAL::Object';
use roles  'Cor::Parser::AST::Role::HasLocation';

use slots (
    slot_locations      => sub { +[] },
    self_call_locations => sub { +[] },
    source              => sub {},
);

sub slot_locations      : ro;
sub self_call_locations : ro;
sub source              : ro;

1;

__END__

=pod

=cut

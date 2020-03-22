package Cor::Parser::AST::Method::Body;
# ABSTRACT: Cor AST for method body definitons

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use parent 'Cor::Parser::AST::Base';

use slots (
    slot_locations => sub { +{} },
    source         => sub {},
);

sub slot_locations : ro;
sub source         : ro;

1;

__END__

=pod

=cut

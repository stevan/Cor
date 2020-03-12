package Cor::Parser::AST::Method::Body;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use parent 'UNIVERSAL::Object';

use slots (
    slot_locations => sub { +{} },
    source         => sub {},
);

sub slot_locations : ro;
sub source         : ro;

sub dump ($self) {
    my %copy = %$self;
    return \%copy;
}

1;

__END__

=pod

=cut

package Cor::Compiler::Unit;
# ABSTRACT: Role representing a compilation unit

use v5.24;
use warnings;
use experimental qw[ signatures ];

use slots (
    ast    => sub {},
    traits => sub {},
);

sub generate_source;

sub dependencies;

1;

__END__

=pod

=cut

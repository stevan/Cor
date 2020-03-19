package Cor::Compiler::Unit;
# ABSTRACT: Role representing a compilation unit

use v5.24;
use warnings;
use experimental qw[ signatures ];

use slots (
    ast => sub {},
);

sub name ($self) { $self->{ast}->name }

sub generate_source;

sub dependencies;

1;

__END__

=pod

=cut

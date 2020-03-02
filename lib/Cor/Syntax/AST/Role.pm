package Cor::Syntax::AST::Role;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use parent 'Cor::Syntax::AST::Base';

use slots (
    name    => sub { undef },
    version => sub { undef },
    roles   => sub { []    },
    slots   => sub { []    },
    methods => sub { []    },
);

sub name    : ro;
sub version : ro;
sub roles   : ro;
sub slots   : ro;
sub methods : ro;

sub set_name    : wo;
sub set_version : wo;

sub add_role ($self, $role) {
    # TODO - test that $role is a Builder::Reference
    push $self->{roles}->@* => $role;
}

sub add_slot ($self, $slot) {
    # TODO - test that $slot is a Builder::Slot
    push $self->{slots}->@* => $slot;
}

sub add_method ($self, $method) {
    # TODO - test that $method is a Builder::Method
    push $self->{methods}->@* => $method;
}

sub has_name    : predicate;
sub has_version : predicate;
sub has_roles   ($self) { !! $self->{roles}->@*   }
sub has_slots   ($self) { !! $self->{slots}->@*   }
sub has_methods ($self) { !! $self->{methods}->@* }

1;

__END__

=pod

=cut

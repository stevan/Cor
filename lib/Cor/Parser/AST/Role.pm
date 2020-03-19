package Cor::Parser::AST::Role;
# ABSTRACT: Cor AST for role declarations

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use parent 'Cor::Parser::AST::Base';

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

# ...

sub has_role   ($self, $name) { !! scalar grep $_->name eq $name, $self->{roles}->@*   }
sub has_slot   ($self, $name) { !! scalar grep $_->name eq $name, $self->{slots}->@*   }
sub has_method ($self, $name) { !! scalar grep $_->name eq $name, $self->{methods}->@* }

1;

__END__

=pod

=cut

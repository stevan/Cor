package Cor::Parser::AST::Class;
# ABSTRACT: Cor AST for class declarations

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use Cor::Parser::AST::Constructor;

use parent 'Cor::Parser::AST::Role';

use slots (
    superclasses => sub { [] },
    constructor  => sub { Cor::Parser::AST::Constructor->new },
);

sub superclasses : ro;
sub constructor  : ro;

sub add_superclass ($self, $superclass) {
    # TODO - test that $superclass is a Builder::Reference
    push $self->{superclasses}->@* => $superclass;
}

sub has_superclasses ($self) { !! $self->{superclasses}->@* }

sub has_superclass ($self, $name) { !! scalar grep $_->name eq $name, $self->{methods}->@* }

sub add_slot ($self, $slot) {
    $self->next::method( $slot );

    # XXX: make sure that $slot has a name

    $self->{constructor}->add_parameter_mapping(
        $slot->identifier,
        $slot->name
    );
}

1;

__END__

=pod

=cut

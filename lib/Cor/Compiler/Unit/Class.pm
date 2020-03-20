package Cor::Compiler::Unit::Class;
# ABSTRACT: compilation unit for classes

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

use parent 'Cor::Compiler::Unit::Role';

use slots;

sub dependencies ($self) {
    return $self->next::method, $self->{ast}->superclasses->@*
}

sub preamble ($self) {
    return (
        $self->next::method,
        # make sure UNIVERSAL::Object is loaded
        # if we are going to make use of it
        (scalar $self->{ast}->superclasses->@* == 0
            ? 'use UNIVERSAL::Object;'
            : ()),
        $self->generate_superclasses,
    )
}

sub generate_superclasses ($self) {
    my $meta = $self->{ast};

    my @superclasses = map $_->name, $self->{ast}->superclasses->@*;

    # if there is no superclass ...
    if ( scalar @superclasses == 0 ) {
        # make it a UNIVERSAL::Object subclass
        push @superclasses => 'UNIVERSAL::Object';
    }

    my @src;
    push @src => '# superclasses';
    push @src => 'our @ISA; BEGIN { @ISA = qw['.(join ' ' => @superclasses).'] }';
    return @src;
}

sub generate_slots ($self) {
    my $meta = $self->{ast};
    my @src  = $self->next::method();

    # inherit the slots at compile time ...
    if ( my @superclasses = map $_->name, $self->{ast}->superclasses->@* ) {
        my $close = pop @src;
        push @src => map {
            '    %'.$_.'::HAS,'
        } @superclasses;
        push @src => $close;
    }

    return @src;
}

1;

__END__

=pod

=cut

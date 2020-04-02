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
        $self->generate_constructor,
    )
}

sub generate_constructor ($self) {
    my $meta = $self->{ast};
    my $ctor = $meta->constructor;
    my %map  = $ctor->parameter_mappings->%*;

    my @src;
    push @src => '# constructor';
    push @src => 'sub BUILDARGS ($class, %args) {';
    push @src => 'my %proto;';

    if ( $meta->has_superclasses ) {
        # NOTE:
        # This is a dangerous assumption
        # about the parent BUILDARGS method
        # we will need to be smarter here
        # - SL
        push @src => '%proto = $class->next::method( %args )->%*;'
    }

    foreach my $param ( sort keys %map ) {

        my $slot_name = $map{$param};
        my $slot      = $meta->get_slot( $slot_name );

        if ( $slot->has_attributes && $slot->has_attribute('private') ) {
            push @src => 'die \'Illegal Arg: `'.$param.'` is a private slot\' if exists $args{q['.$param.']};';
        }
        else {
            push @src => '$proto{q['.$slot_name.']} = $args{q['.$param.']} if exists $args{q['.$param.']};'
        }
    }
    push @src => 'return \%proto;';
    push @src => '}';
    return @src;
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

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
    my %map  = map { $_->identifier => $_ } $meta->slots->@*;

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

        my $slot = $map{$param};

        if (
            ($slot->has_attributes && $slot->has_attribute('private'))
                ||
            ($slot->name =~ /^\$\!/)
        ) {
            push @src => 'die \'Illegal Arg: `'.$param.'` is a private slot\' if exists $args{q['.$param.']};';
        }
        else {
            push @src => '$proto{q['.$slot->name.']} = $args{q['.$param.']} if exists $args{q['.$param.']};'
        }
    }
    push @src => 'return \%proto;';
    push @src => '}';
    return @src;
}

sub generate_superclass_reference_name ($self, $reference) {

    my $name;
    if ( $reference->has_module && exists $self->{module_map}->{ $reference->name } ) {
        $name = $reference->module->name . '::' . $reference->name;
    }
    else {
        $name = $reference->name;
    }

    return $name;
}

sub generate_superclasses ($self) {
    my $meta = $self->{ast};

    my @superclasses = map $self->generate_superclass_reference_name( $_ ), $self->{ast}->superclasses->@*;

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
    if ( my @superclasses = map $self->generate_superclass_reference_name( $_ ), $self->{ast}->superclasses->@* ) {
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

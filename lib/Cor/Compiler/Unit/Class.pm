package Cor::Compiler::Unit::Class;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use parent 'Cor::Compiler::Unit::Role';

use slots (
    ast => sub {},
);

sub dependencies ($self) {
    return $self->next::method, $self->{ast}->superclasses->@*
}

sub preamble ($self) {
    return (
        $self->next::method,
        $self->generate_superclasses,
    )
}

sub generate_superclasses ($self) {
    my $meta = $self->{ast};

    # we always want to make sure we inherit
    # slots when they are available
    push $self->{_UNITCHECK}->@* => 'MOP::Util::inherit_slots($META);';

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

1;

__END__

=pod

=cut

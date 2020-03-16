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
        '# superclasses',
        'our @ISA; BEGIN { @ISA = qw[',
            (map $_->name, $self->{ast}->superclasses->@*),
        '] }',
    )
}

1;

__END__

=pod

=cut

package Cor::Compiler::Unit::Role;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use parent 'UNIVERSAL::Object';

use slots (
    ast => sub {},
);

sub dependencies ($self) {
    return $self->{ast}->roles->@*
}

sub preamble ($self) {
    return (
        'use v5.24;',
        'use warnings;',
        'use experimental qw[ signatures postderef ];',
        'use decorators qw[ :accessors :constructor ];',
        'use MOP::Util ();',
    )
}

sub generate_source ($self) {

    my $meta = $self->{ast};

    my @src;
    push @src => 'package '
                . $meta->name
                . ($meta->has_version ? ' ' . ($meta->version =~ s/^v//r) : '')
                . ' {';

    push @src => $self->preamble;

    if ( $meta->has_roles ) {
        push @src => $self->generate_roles;
    }

    if ( $meta->has_slots ) {
        push @src => $self->generate_slots;
    }

    if ( $meta->has_methods ) {
        push @src => $self->generate_methods;
    }

    push @src => '}';

    return join "\n" => @src;
}

sub generate_roles ($self) {
    my $meta = $self->{ast};

    my @src;
    push @src => '# roles';
    push @src => 'our @DOES; BEGIN { @DOES = qw['
        . (join ' ' => map $_->name, $meta->roles->@*)
    . '] }';
    # TODO
    # Improve UNITCHECK handling so
    # that we can do them in a single
    # block and not multiple blocks
    # each doing very similar things
    # - SL
    push @src => 'UNITCHECK { MOP::Util::compose_roles(MOP::Util::get_meta(q[' . $meta->name . '])) }';
    return @src;
}

sub generate_slots ($self) {
    my $meta = $self->{ast};

    my @src;
    push @src => '# slots';
    push @src => 'our %HAS; BEGIN { %HAS = (';
    push @src => map {
    '    q[' . $_->name . '] => sub { ' . ($_->has_default ? $_->default : '') . ' },'
    } $meta->slots->@*;
    push @src => ') }';
    # TODO
    # see TODO above about other
    # UNITCHECK block
    # - SL
    push @src => 'UNITCHECK { MOP::Util::inherit_slots(MOP::Util::get_meta(q[' . $meta->name . '])) }';
    return @src;
}

sub generate_methods ($self) {
    my $meta = $self->{ast};

    my @src;
    push @src => '# methods';
    push @src => map {
        'sub '
        . $_->name
        . ($_->has_attributes ? ' ' . $_->attributes : '')
        . ($_->has_signature  ? ' ' . $_->signature  : '')
        . ($_->is_abstract
            ? ';'
            : ' ' . $self->_compile_method_body( $_->body ))
    } $meta->methods->@*;
    return @src;
}

# ...

sub _compile_method_body ($self, $body) {

    my $source  = $body->source;
    my @matches = $body->slot_locations->@*;

    my $source_length = length( $source );

    my $offset = 0;
    foreach my $m ( @matches ) {
        my $patch = '$_[0]->{q[' . $m->{match} . ']}';

        #use Data::Dumper;
        #warn Dumper [ $m, [
        #    $source,
        #    $source_length,
        #    $m->{start} + $offset,
        #    length( $m->{match} )
        #    ] ];

        substr(
            $source,
            $m->{start} + $offset,
            length( $m->{match} ),
        ) = $patch;
        $offset += length( $patch ) - length( $m->{match} );
    }

    return $source;

}

1;

__END__

=pod

=cut

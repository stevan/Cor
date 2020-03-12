package Cor::Compiler::SimpleCompiler;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

our $INDENT = '    ';

our @MODULE_PREAMBLE = (
    'use v5.24;',
    'use warnings;',
    'use experimental qw[ signatures postderef ];',
    'use decorators qw[ :accessors :constructor ];',
);

sub compile ($meta) {
    my @src;

    push @src => 'package '
                . $meta->name
                . ($meta->has_version ? ' ' . ($meta->version =~ s/^v//r) : '')
                . ' {';

    push @src => @MODULE_PREAMBLE;

    if ( $meta->isa('Cor::Syntax::AST::Class') && $meta->has_superclasses ) {
        push @src => '# superclasses';
        push @src => 'our @ISA; BEGIN { @ISA = qw['
            . (join ' ' => map $_->name, $meta->superclasses->@*)
        . '] }';
    }

    if ( $meta->has_roles ) {
        push @src => '# roles';
        push @src => 'our @DOES; BEGIN { @DOES = qw['
            . (join ' ' => map $_->name, $meta->roles->@*)
        . '] }';
    }

    if ( $meta->has_slots ) {
        push @src => '# slots';
        push @src => 'our %HAS; BEGIN { %HAS = (';
        push @src => map {
                $INDENT
                . 'q[' . $_->name . '] => sub { '
                . ($_->has_default ? $_->default : '')
                . ' },'
        } $meta->slots->@*;
        push @src => ') }';
    }

    if ( $meta->has_methods ) {
        push @src => '# methods';
        push @src => map {
                'sub '
                . $_->name
                . ($_->has_attributes ? ' ' . $_->attributes : '')
                . ($_->has_signature  ? ' ' . $_->signature  : '')
                . ($_->is_abstract
                    ? ';'
                    : ' ' . compile_method_body( $_->body ))
        } $meta->methods->@*;
    }

    push @src => '}';

    return join "\n" => @src;
}

sub compile_method_body ($body) {

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
        $offset = length( $patch ) - length( $m->{match} );
    }

    return $source;

}

1;

__END__

=pod

=cut

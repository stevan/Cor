package Cor::Compiler::SimpleCompiler;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

our $INDENT = '    ';

sub compile ($meta) {
    my @src;

    push @src => 'package '
                . $meta->name
                . ($meta->has_version ? ' ' . ($meta->version =~ s/^v//r) : '')
                . ' {';

    push @src => 'use v5.24;';
    push @src => 'use warnings;';
    push @src => 'use experimental qw[ signatures postderef ];';
    push @src => 'use decorators qw[ :accessors :constructor ];';

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
                    : $_->body)
        } $meta->methods->@*;
    }

    push @src => '}';

    return join "\n" => @src;
}

1;

__END__

=pod

=cut

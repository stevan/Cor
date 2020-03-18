package Cor::Compiler;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

use Cor::Compiler::Unit::Role;
use Cor::Compiler::Unit::Class;

sub compile ($asts) {

    my @units = map {
        $_->isa('Cor::Parser::AST::Class')
            ? Cor::Compiler::Unit::Class->new( ast => $_ )
            : Cor::Compiler::Unit::Role->new( ast => $_ )
    } $asts->@*;

    my @compiled = map {
        _compile_dependencies( $_->dependencies ),
        $_->generate_source
    } @units;

    # TODO:
    # add a compilation unit
    # seperator here, think
    # multi-part mime messages
    # or something, add some
    # metadata to the compiled
    # product
    # - SL
    return join "\n" => @compiled;
}

sub _compile_dependencies ( @dependencies ) {
    return unless @dependencies;

    my @src;
    push @src => 'BEGIN {';
    push @src => 'use Cor;';
    push @src => map {
        'Cor::load(q['.$_->name.']);'
    } @dependencies;
    push @src => '}';
    return @src;
}

1;

__END__

=pod

=cut

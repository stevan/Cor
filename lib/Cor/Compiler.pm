package Cor::Compiler;
# ABSTRACT: Compiler for Cor object

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

    my %unit_index = map {
        ($_->name => undef)
    } @units;

    my @compiled = map {
        # filter out any dependencies contained
        # here in this compilation group ...
        (map { 'use '.$_->name.';' }
            grep not( exists $unit_index{ $_->name } ), $_->dependencies),
        # generate the source ...
        $_->generate_source,
    } @units;

    return join "\n" => @compiled;
}

1;

__END__

=pod

=cut

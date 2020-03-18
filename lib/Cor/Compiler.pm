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

    my @dependencies = map {
        $_->dependencies
    } @units;

    #use Data::Dumper;
    #warn Dumper \@dependencies;

    my @compiled;

    if ( @dependencies ) {
        push @compiled => 'BEGIN {';
        push @compiled => 'use Cor;';
        push @compiled => map {
            'Cor::load(q['.$_->name.']);'
        } @dependencies;
        push @compiled => '}';
        #warn join "\n" => @compiled;
    }

    push @compiled => map {
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

1;

__END__

=pod

=cut

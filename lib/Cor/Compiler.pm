package Cor::Compiler;
# ABSTRACT: Compiler for Cor object

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

use Cor::Compiler::Unit::Role;
use Cor::Compiler::Unit::Class;

use parent 'UNIVERSAL::Object';

use slots (
    asts => sub {},
    # ...
    _units        => sub {},
    _dependencies => sub {},
);

sub BUILD ($self, $params) {

    my @asts          = $self->{asts}->@*;
    my %package_index = map { $_->name => undef } @asts;

    my @units = map {
        $_->isa('Cor::Parser::AST::Class')
            ? Cor::Compiler::Unit::Class->new( ast => $_ )
            : Cor::Compiler::Unit::Role->new( ast => $_ )
    } @asts;

    my @dependencies = map {
        # filter out any dependencies contained
        # here in this compilation group ...
        (grep not( exists $package_index{ $_->name } ), $_->dependencies)
    } @units;

    $self->{_units}        = \@units;
    $self->{_dependencies} = \@dependencies;
}

sub compile ($self) {

    my @compiled = map { 'use '.$_->name.';' } $self->{_dependencies}->@*;

    push @compiled => map $_->generate_source, $self->{_units}->@*;

    return join "\n" => @compiled;
}

1;

__END__

=pod

=cut

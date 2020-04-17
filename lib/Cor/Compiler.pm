package Cor::Compiler;
# ABSTRACT: Compiler for Cor object

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

use Cor::Compiler::Unit::Role;
use Cor::Compiler::Unit::Class;

use Cor::Compiler::Traits;

use parent 'UNIVERSAL::Object';

use slots (
    doc        => sub {},
    traits     => sub { +{} },
    module_map => sub { +{} },
    # ...
    _units        => sub {},
    _dependencies => sub {},
);

sub BUILD ($self, $params) {

    my @asts          = $self->{doc}->asts->@*;
    my %package_index = map { $_->name => undef } @asts;

    # combine user supplied traits with core ones ...
    my %traits = ( $self->{traits}->%*, %Cor::Compiler::Traits::TRAITS );

    my @units = map {
        $_->isa('Cor::Parser::AST::Class')
            ? Cor::Compiler::Unit::Class->new( ast => $_, traits => \%traits, module_map => $self->{module_map} )
            :  Cor::Compiler::Unit::Role->new( ast => $_, traits => \%traits, module_map => $self->{module_map} )
    } @asts;

    my @dependencies = map {
        # transform the dependency name
        # based on the module mapping
        $_->set_name( $self->{module_map}->{ $_->name } )
            if exists $self->{module_map}->{ $_->name };
        # return the item
        $_;
    } map {
        # filter out any dependencies contained
        # here in this compilation group ...
        (grep not( exists $package_index{ $_->name } ), $_->dependencies)
    } @units;

    #use Data::Dumper;
    #warn Dumper \@dependencies;

    $self->{_units}        = \@units;
    $self->{_dependencies} = \@dependencies;
}

sub list_dependencies ($self) { map $_->name, $self->{_dependencies}->@* }

sub compile ($self) {

    my @compiled;

    push @compiled => $self->{doc}->use_statements->@*;
    push @compiled => map { 'use '.$_->name.';' } $self->{_dependencies}->@*;
    push @compiled => map $_->generate_source, $self->{_units}->@*;

    return join "\n" => @compiled;
}

1;

__END__

=pod

=cut

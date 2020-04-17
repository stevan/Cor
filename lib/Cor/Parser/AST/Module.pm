package Cor::Parser::AST::Module;
# ABSTRACT: Cor AST for module declarations

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use List::Util;

use parent 'UNIVERSAL::Object';
use roles  'Cor::Parser::AST::Role::HasLocation';

use slots (
    name => sub {},
    # internal
    _classes => sub { +{} },
    _roles   => sub { +{} },
);

sub name     : ro;
sub set_name : wo;
sub has_name : predicate;

# ...

sub has_associated_class ($self, $name) { exists $self->{_classes}->{ $name } }
sub has_associated_role  ($self, $name) { exists $self->{_roles  }->{ $name } }

sub associate_class ($self, $class) {
    $self->{_classes}->{ $class->name } = $class;
}

sub associate_role ($self, $role) {
    $self->{_roles}->{ $role->name } = $role;
}


1;

__END__

=pod

=cut

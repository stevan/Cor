package Cor::Parser::AST::Constructor;
# ABSTRACT: Cor AST for class declarations

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use parent 'UNIVERSAL::Object';

use slots (
    _param_map => sub { +{} },
);

sub parameter_mappings : ro(_param_map);

sub add_parameter_mapping ($self, $name, $param_name) {
    $self->{_param_map}->{$name} = $param_name;
}

sub remove_parameter_mapping ($self, $name) {
    delete $self->{_param_map}->{$name};
}

sub has_parameter_mapping ($self, $name) {
    exists $self->{_param_map}->{$name}
}

1;

__END__

=pod

=cut

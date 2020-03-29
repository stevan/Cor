package Cor::Parser::AST::Role::HasAttributes;
# ABSTRACT: Cor AST for AST entity which has attributes

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use slots (
    attributes => sub { [] },
);

sub attributes : ro;
sub set_attributes : wo;
sub has_attributes ($self) { !! $self->{attributes}->@* }

sub has_attribute ($self, $name) {
    !! scalar grep { $_->name eq $name } $self->{attributes}->@*
}

1;

__END__

=pod

=cut

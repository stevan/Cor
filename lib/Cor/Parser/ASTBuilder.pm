package Cor::Parser::ASTBuilder;
# ABSTRACT: Cor AST builder

use v5.24;
use warnings;
use experimental qw[ signatures ];

use Cor::Parser::AST::Role;
use Cor::Parser::AST::Class;

use Cor::Parser::AST::Reference;

use Cor::Parser::AST::Slot;
use Cor::Parser::AST::Method;

use Cor::Parser::AST::Method::Body;

use Cor::Parser::AST::Location;
use Cor::Parser::AST::Attribute;

sub new_location_at ($char_at) {
    Cor::Parser::AST::Location->new( char_at => $char_at )
}

sub new_role_at      {      Cor::Parser::AST::Role->new( start_location => new_location_at( @_ ) ) }
sub new_class_at     {     Cor::Parser::AST::Class->new( start_location => new_location_at( @_ ) ) }
sub new_reference_at { Cor::Parser::AST::Reference->new( start_location => new_location_at( @_ ) ) }
sub new_slot_at      {      Cor::Parser::AST::Slot->new( start_location => new_location_at( @_ ) ) }
sub new_method_at    {    Cor::Parser::AST::Method->new( start_location => new_location_at( @_ ) ) }

sub new_method_body_at ( $source, $matches, $char_at ) {
    Cor::Parser::AST::Method::Body->new(
        source         => $source,
        slot_locations => $matches,
        start_location => new_location_at( $char_at ),
    )
}

sub new_attributes_at ( $source, $attributes, $char_at ) {
    # NOTE:
    # ignore $source for now, we might want it later
    map {
        Cor::Parser::AST::Attribute->new(
            name           => $_->{match}->{name},
            args           => $_->{match}->{args},
            start_location => new_location_at( $char_at + $_->{start} ),
            end_location   => new_location_at( $char_at + $_->{end}   ),
        )
    } $attributes->@*
}

sub set_end_location ($ast, $char_at) {
    $ast->set_end_location( new_location_at( $char_at ) );
}

1;

__END__

=pod

=cut

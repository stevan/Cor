package Cor::Syntax::ASTBuilder;

use v5.24;
use warnings;
use experimental qw[ signatures ];

use Cor::Syntax::AST::Role;
use Cor::Syntax::AST::Class;

use Cor::Syntax::AST::Reference;

use Cor::Syntax::AST::Slot;
use Cor::Syntax::AST::Method;

use Cor::Syntax::AST::Method::Body;

use Cor::Syntax::AST::Location;

sub new_location_at ($char_number, $line_number) {
    return Cor::Syntax::AST::Location->new(
        char_number => $char_number,
        line_number => $line_number,
    )
}

sub new_role_at      {      Cor::Syntax::AST::Role->new( start_location => new_location_at( @_ ) ) }
sub new_class_at     {     Cor::Syntax::AST::Class->new( start_location => new_location_at( @_ ) ) }
sub new_reference_at { Cor::Syntax::AST::Reference->new( start_location => new_location_at( @_ ) ) }
sub new_slot_at      {      Cor::Syntax::AST::Slot->new( start_location => new_location_at( @_ ) ) }
sub new_method_at    {    Cor::Syntax::AST::Method->new( start_location => new_location_at( @_ ) ) }

sub new_method_body_at ( $source, $matches ) {
    Cor::Syntax::AST::Method::Body->new( source => $source, slot_locations => $matches )
}

sub set_end_location ($ast, @location) {
    $ast->set_end_location( new_location_at( @location ) );
}

1;

__END__

=pod

=cut

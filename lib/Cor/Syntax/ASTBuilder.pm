package Cor::Syntax::ASTBuilder;

use v5.24;
use warnings;

use Cor::Syntax::AST::Role;
use Cor::Syntax::AST::Class;

use Cor::Syntax::AST::Reference;

use Cor::Syntax::AST::Slot;
use Cor::Syntax::AST::Method;

use Cor::Syntax::AST::Location;

sub new_role_at      {      Cor::Syntax::AST::Role->new( start_location => Cor::Syntax::AST::Location->new( char_number => $_[0], line_number => $_[1] ) ) }
sub new_class_at     {     Cor::Syntax::AST::Class->new( start_location => Cor::Syntax::AST::Location->new( char_number => $_[0], line_number => $_[1] ) ) }
sub new_reference_at { Cor::Syntax::AST::Reference->new( start_location => Cor::Syntax::AST::Location->new( char_number => $_[0], line_number => $_[1] ) ) }
sub new_slot_at      {      Cor::Syntax::AST::Slot->new( start_location => Cor::Syntax::AST::Location->new( char_number => $_[0], line_number => $_[1] ) ) }
sub new_method_at    {    Cor::Syntax::AST::Method->new( start_location => Cor::Syntax::AST::Location->new( char_number => $_[0], line_number => $_[1] ) ) }

1;

__END__

=pod

=cut

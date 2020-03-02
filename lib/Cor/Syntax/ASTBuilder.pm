package Cor::Syntax::ASTBuilder;

use v5.24;
use warnings;

use Cor::Syntax::AST::Role;
use Cor::Syntax::AST::Class;

use Cor::Syntax::AST::Reference;

use Cor::Syntax::AST::Slot;
use Cor::Syntax::AST::Method;

use Cor::Syntax::AST::Location;

sub new_role_at      {      Cor::Syntax::AST::Role->new( location => Cor::Syntax::AST::Location->new( start => $_[0] ) ) }
sub new_class_at     {     Cor::Syntax::AST::Class->new( location => Cor::Syntax::AST::Location->new( start => $_[0] ) ) }
sub new_reference_at { Cor::Syntax::AST::Reference->new( location => Cor::Syntax::AST::Location->new( start => $_[0] ) ) }
sub new_slot_at      {      Cor::Syntax::AST::Slot->new( location => Cor::Syntax::AST::Location->new( start => $_[0] ) ) }
sub new_method_at    {    Cor::Syntax::AST::Method->new( location => Cor::Syntax::AST::Location->new( start => $_[0] ) ) }

1;

__END__

=pod

=cut

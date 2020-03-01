package Cor::Builder;

use v5.24;
use warnings;

use Cor::Builder::Role;
use Cor::Builder::Class;

use Cor::Builder::Reference;

use Cor::Builder::Slot;
use Cor::Builder::Method;

use Cor::Builder::Location;

sub new_role_at      {      Cor::Builder::Role->new( location => Cor::Builder::Location->new( start => $_[0] ) ) }
sub new_class_at     {     Cor::Builder::Class->new( location => Cor::Builder::Location->new( start => $_[0] ) ) }
sub new_reference_at { Cor::Builder::Reference->new( location => Cor::Builder::Location->new( start => $_[0] ) ) }
sub new_slot_at      {      Cor::Builder::Slot->new( location => Cor::Builder::Location->new( start => $_[0] ) ) }
sub new_method_at    {    Cor::Builder::Method->new( location => Cor::Builder::Location->new( start => $_[0] ) ) }

1;

__END__

=pod

=cut

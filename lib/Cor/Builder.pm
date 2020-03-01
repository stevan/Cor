package Cor::Builder;

use v5.24;
use warnings;

use Cor::Builder::Role;
use Cor::Builder::Class;

use Cor::Builder::Reference;

use Cor::Builder::Slot;
use Cor::Builder::Method;

use Cor::Builder::Location;

sub new_role      {      Cor::Builder::Role->new( location => Cor::Builder::Location->new( @_ ) ) }
sub new_class     {     Cor::Builder::Class->new( location => Cor::Builder::Location->new( @_ ) ) }
sub new_reference { Cor::Builder::Reference->new( location => Cor::Builder::Location->new( @_ ) ) }
sub new_slot      {      Cor::Builder::Slot->new( location => Cor::Builder::Location->new( @_ ) ) }
sub new_method    {    Cor::Builder::Method->new( location => Cor::Builder::Location->new( @_ ) ) }

1;

__END__

=pod

=cut

package Cor::Builder;

use v5.24;
use warnings;

use Cor::Builder::Role;
use Cor::Builder::Class;

use Cor::Builder::Reference;

use Cor::Builder::Slot;
use Cor::Builder::Method;

sub new_role      { Cor::Builder::Role->new( @_ )      }
sub new_class     { Cor::Builder::Class->new( @_ )     }
sub new_reference { Cor::Builder::Reference->new( @_ ) }
sub new_slot      { Cor::Builder::Slot->new( @_ )      }
sub new_method    { Cor::Builder::Method->new( @_ )    }

1;

__END__

=pod

=cut

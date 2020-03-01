package Cor::Builder::Reference;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use parent 'UNIVERSAL::Object';
use roles  'Cor::Builder::Role::Dumpable';

use slots (
    name    => sub {},
    version => sub {},
);

sub set_name    : wo(name);
sub set_version : wo(version);

1;

__END__

=pod

=cut

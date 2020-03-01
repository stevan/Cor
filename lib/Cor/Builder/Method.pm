package Cor::Builder::Method;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use parent 'UNIVERSAL::Object';
use roles  'Cor::Builder::Role::Dumpable';

use slots (
    name        => sub {},
    attributes  => sub {},
    signature   => sub {},
    body        => sub {},
    is_abstract => sub {},
);

sub set_name       : wo(name);
sub set_attributes : wo(attributes);
sub set_signature  : wo(signature);
sub set_body       : wo(body);
sub is_abstract    : wo;

# alias
*set_is_abstract = \&is_abstract;

1;

__END__

=pod

=cut

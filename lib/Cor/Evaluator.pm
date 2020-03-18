package Cor::Evaluator;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

sub evaluate ($src) {

    # TODO
    # Improve this error handling.
    # A lot.
    # - SL
    local $@ = undef;
    eval $src;
    if ( $@ ) {
        die $@;
    }

    return $src;
}

1;

__END__

=pod

=cut

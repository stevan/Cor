package Cor::Evaluator;
# ABSTRACT: Simple evaluator

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

# NOTE:
# this is not really meant to be an important
# component, it is mostly useful for testing
# when we are constructing Cor classes as strings
# and want to test stuff, I would recommend to
# not take it very seriously.
# - SL

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

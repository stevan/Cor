package Cor::Compiler;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

use Cor::Compiler::Unit;

sub compile ($asts) {

    my $unit = Cor::Compiler::Unit->new( asts => $asts );

    my $src = $unit->generate_source;

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

package Cor;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

use Cor::Parser;
use Cor::Compiler;

sub load_file ($filename) {
    open( my $fh, "<", $filename )
        or die "Could not open file:[$filename] because:[$!]";
    return load_filehandle( $fh );
}

sub load_filehandle ($fh) {

    my $original = join '' => <$fh>;
    my $asts     = Cor::Parser::parse( $original );
    my $compiled = Cor::Compiler::compile( $asts );

    return (
        $compiled,
        $asts
    );
}

1;

__END__

=pod

=cut

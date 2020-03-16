package Cor;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

use Cor::Parser;
use Cor::Compiler::SimpleCompiler;

sub load_file ($filename) {
    open( my $fh, "<", $filename )
        or die "Could not open file:[$filename] because:[$!]";
    return load_filehandle( $fh );
}

sub load_filehandle ($fh) {

    my $original = join '' => <$fh>;
    my $matches  = Cor::Parser::parse( $original );

    my @compiled;
    foreach my $ast ( $matches->@* ) {
        push @compiled => Cor::Compiler::SimpleCompiler::compile( $ast );
    }

    my $compiled_source = join "\n" => @compiled;

    # TODO
    # Improve this error handling.
    # A lot.
    # - SL
    local $@ = undef;
    eval $compiled_source;
    if ( $@ ) {
        die $@;
    }

    return (
        $compiled_source,
        $matches
    );
}

1;

__END__

=pod

=cut

package Cor;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

use Cor::Parser;
use Cor::Compiler;
use Cor::Evaluator;

sub load ($package_name) {

    my $package_path = (join '/' => split /\:\:/ => $package_name) . '.pm';

    # do not reload if we have them
    return (undef, undef) if exists $INC{$package_path};

    my $full_package_path;

    my @inc = @INC;
    my $inc;
    while ( $inc = shift @inc ) {
        next if ref $inc; # skip them for now ...

        # build the path
        $full_package_path = $inc.'/'.$package_path;
        # jump out of loop if we found it
        last if -f $full_package_path;
        # otherwise undef the variable
        # and continue checking
        undef $full_package_path;
    }

    die "Could not find [$package_name] in \@INC paths"
        if not defined $full_package_path;

    $INC{$package_path} = $full_package_path;

    open( my $fh, "<", $full_package_path )
        or die "Could not open [$package_name] at [$full_package_path] because [$!]";

    my $original = join '' => <$fh>;
    my $asts     = Cor::Parser::parse( $original );
    my $compiled = Cor::Compiler::compile( $asts );

    Cor::Evaluator::evaluate( $compiled );

    return (
        $compiled,
        $asts
    );
}

1;

__END__

=pod

=cut

package Cor;
# ABSTRACT: A core object system for Perl 5

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

use Cor::Parser;
use Cor::Compiler;

sub build ($package_name) {

    my $package_path = (join '/' => split /\:\:/ => $package_name) . '.pm';

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

    die "Could not find [$package_path] in \@INC paths"
        if not defined $full_package_path;

    open( my $fh, "<", $full_package_path )
        or die "Could not open [$package_name] at [$full_package_path] because [$!]";
    my $original = join '' => <$fh>;
    close $fh
        or die "Could not close [$full_package_path] because [$!]";

    my $asts     = Cor::Parser::parse( $original );
    my $compiler = Cor::Compiler->new( asts => $asts );
    my $compiled = $compiler->compile;
    my $pmc_path = $full_package_path.'c';

    open( my $pmc, ">", $pmc_path )
        or die "Could not open [$pmc_path] because [$!]";
    print $pmc $compiled;
    close $pmc
        or die "Could not close [$pmc_path] because [$!]";;

    return $pmc_path;
}

1;

__END__

=pod

=cut

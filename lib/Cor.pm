package Cor;
# ABSTRACT: A core object system for Perl 5

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

use IO::File        ();
use File::Spec      ();
use Module::Runtime ();

use Cor::Parser;
use Cor::Compiler;

use constant DEBUG => $ENV{COR_DEBUG} // 0;

sub build ($resource, %opts) {

    my $full_package_path = find_module_path_in_INC( $resource )
        or die "Could not find [$resource] in \@INC paths";

    my $original = read_source_file( $full_package_path );
    my $doc      = Cor::Parser::parse( $original );
    my $compiler = Cor::Compiler->new( doc => $doc );

    #use Data::Dumper; warn Dumper $asts;

    my @built;

    if ( $opts{recurse} ) {
        my @dependencies = $compiler->list_dependencies;
        foreach my $dep ( @dependencies ) {
            push @built => build( $dep, recurse => 1 );
        }
    }

    my $compiled = $compiler->compile;
    push @built => write_pmc_file( $full_package_path, $compiled );

    return @built;
}

sub find_module_path_in_INC ($resource) {
    my @inc = @INC;

    my $package_path;

    # if it is an absolute file path, just return it
    return $resource if File::Spec->file_name_is_absolute( $resource );

    if ( Module::Runtime::is_module_name( $resource ) ) {
        $package_path = Module::Runtime::module_notional_filename( $resource );
    }
    else {
        $package_path = $resource;
    }

    my ($inc, $full_package_path);
    while ( $inc = shift @inc ) {
        next if ref $inc; # skip them for now ...

        # build the path
        $full_package_path = File::Spec->catfile( $inc, $package_path );
        # jump out of loop if we found it
        last if -f $full_package_path;
        # otherwise undef the variable
        # and continue checking
        undef $full_package_path;
    }

    return $full_package_path;
}

sub read_source_file ($full_package_path) {

    my $fh = IO::File->new;
    $fh->open( $full_package_path, 'r' )
        or die "Could not open [$full_package_path] because [$!]";
    my $source = join '' => <$fh>;
    $fh->close
        or die "Could not close [$full_package_path] because [$!]";

    return $source;
}

sub write_pmc_file ($full_package_path, $compiled) {
    my $pmc_path = $full_package_path.'c';

    my $pmc = IO::File->new;
    $pmc->open( $pmc_path, 'w' )
        or die "Could not open [$pmc_path] because [$!]";
    $pmc->print($compiled);
    $pmc->close
        or die "Could not close [$pmc_path] because [$!]";;

    return $pmc_path;
}

1;

__END__

=pod

=cut

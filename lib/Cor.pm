package Cor;
# ABSTRACT: A core object system for Perl 5

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

use IO::File        ();
use IO::Dir         ();
use File::Spec      ();
use Module::Runtime ();

use Cor::Parser;
use Cor::Compiler;

use constant DEBUG => $ENV{COR_DEBUG} // 0;

our %COR_INC;

sub build_module ($module, %opts) {

    my ($module_root, $module_dir) = find_module_path_in_INC( $module );

    warn "Building module [$module]($module_dir) in ($module_root)\n" if DEBUG;

       $module_root = File::Spec->catfile( $module_root ); # clean this to be like module_path
    my $module_path = File::Spec->catfile( $module_root, $module_dir );

    my @contents = find_module_contents( $module_path );

    #use Data::Dumper;
    #warn Dumper \@contents;

    my %packages = map {
        # strip off the module package
        s/$module\:\://r => $_
    } map {
        s/^$module_root\///; # strip off the root directory
        s/\.pm$//;           # strip off the file extension
        s/\//\:\:/gr;        # transform path (/) to package (::)
    } @contents;

    #warn $module_root;
    #warn $module_dir;
    #warn $module_path;
    #use Data::Dumper;
    #warn Dumper \%packages;

    my @built;
    foreach my $k ( keys %packages ) {
        push @built => build( $packages{ $k }, %opts, module_map => \%packages );
    }

    return @built;
}

sub find_module_contents ($module_dir) {

    my @contents;

    my $dir = IO::Dir->new( $module_dir );

    while ( my $child = $dir->read ) {
        next if $child =~ /^\./;

        my $child_path = File::Spec->catfile( $module_dir, $child );

        if ( -f $child_path ) {
            next unless $child =~ /\.pm$/;
            push @contents => $child_path;
        }
        elsif ( -d $child_path ) {
            push @contents => find_module_contents( $child_path );
        }
        else {
            # ignore anything else for now
        }
    }

    return @contents;
}

sub build ($resource, %opts) {

    my ($package_dir, $package_path) = find_path_in_INC( $resource );

    die "Could not find [$resource] in \@INC paths"
        unless defined $package_dir;

    if ( exists $COR_INC{ $package_path } ) {
        warn "Skipping [$resource]($package_path) it was already built\n" if DEBUG;
        return;
    }

    warn "Building [$resource]($package_path) in ($package_dir)\n" if DEBUG;

    my $full_package_path = File::Spec->catfile( $package_dir, $package_path );

    my $original = read_source_file( $full_package_path );
    my $doc      = Cor::Parser::parse( $original );
    my $compiler = Cor::Compiler->new(
        doc => $doc,
        (exists $opts{module_map}
            ? (module_map => $opts{module_map})
            : ())
    );

    #use Data::Dumper; warn Dumper $asts;

    my @built;

    if ( $opts{recurse} ) {
        my @dependencies = $compiler->list_dependencies;
        foreach my $dep ( @dependencies ) {
            push @built => build( $dep, %opts );
        }
    }

    my $compiled = $compiler->compile;

    my $pmc_file_path = write_pmc_file( $full_package_path, $compiled );

    $COR_INC{ $package_path } = $pmc_file_path;

    return @built, $pmc_file_path;
}

sub find_path_in_INC ($resource) {

    use Carp ();
    Carp::confess("WTF") unless defined $resource;

    my @inc = @INC;

    my $package_path;

    if ( Module::Runtime::is_module_name( $resource ) ) {
        $package_path = Module::Runtime::module_notional_filename( $resource );
    }
    else {
        $package_path = $resource;
    }

    my $inc;
    while ( $inc = shift @inc ) {
        next if ref $inc; # skip them for now ...
        # jump out of loop if we found it
        last if -f File::Spec->catfile( $inc, $package_path );
    }

    return ($inc, $package_path);
}

sub find_module_path_in_INC ($resource) {
    my @inc = @INC;

    my $module_path;

    if ( Module::Runtime::is_module_name( $resource ) ) {
        $module_path = Module::Runtime::module_notional_filename( $resource );
        $module_path =~ s/\.pm$//;
    }
    else {
        $module_path = $resource;
    }

    my $inc;
    while ( $inc = shift @inc ) {
        next if ref $inc; # skip them for now ...
        # jump out of loop if we found it
        last if -d File::Spec->catfile( $inc, $module_path );
    }

    return ($inc, $module_path);
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

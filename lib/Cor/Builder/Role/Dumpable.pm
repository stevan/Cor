package Cor::Builder::Role::Dumpable;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

use Scalar::Util 'blessed';
use roles (); # make sure roles::DOES is available

sub dump ($self) {
    my %copy = %$self;
    foreach my $k ( keys %copy ) {
        # warn "looking at $k ( ", ($copy{ $k } // 'undef'), " ) \n";
        if ( not defined $copy{ $k } ) {
            # prune the output of
            # irrelvant output
            delete $copy{ $k };
            #if ( exists $copy{ $k } ) {
            #    warn "WTF this ($k) should be deleted!!\n";
            #}
        }
        elsif ( ref $copy{ $k } eq 'ARRAY' ) {
            # dump recursively
            $copy{ $k } = [ map {
                #warn "looking at @ $_ (\$copy{ $k }) \n";
                if ( blessed $_ ) {
                    #warn "dumping array item";
                    $_->dump;
                }
                else {
                    $_;
                }
            } $copy{ $k }->@* ];
        }
        elsif ( blessed $copy{ $k } ) {
            # dump recursively
            $copy{ $k } = $copy{ $k }->dump;
        }
    }
    return \%copy;
}

1;

__END__

=pod

=cut

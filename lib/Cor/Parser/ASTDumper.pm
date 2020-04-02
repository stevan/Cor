package Cor::Parser::ASTDumper;
# ABSTRACT: Cor AST dumper

use v5.24;
use warnings;
use experimental qw[ signatures ];

use roles        ();
use Scalar::Util ();

sub dump_ast ($ast) {

    my %copy = %$ast; # fuck encapsulation

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
        elsif ( Scalar::Util::blessed( $copy{ $k } ) && ! $copy{ $k }->roles::DOES('Cor::Parser::AST::Role::HasLocation') ) {
            delete $copy{ $k };
        }
        elsif ( ref $copy{ $k } eq 'ARRAY' ) {
            if ( $copy{ $k }->@* ) {
                # dump recursively
                $copy{ $k } = [ map {
                    #warn "looking at @ $_ (\$copy{ $k }) \n";
                    if ( Scalar::Util::blessed( $_ ) ) {
                        #warn "dumping array item";
                        dump_ast( $_ );
                    }
                    else {
                        $_;
                    }
                } $copy{ $k }->@* ];
            }
            else {
                # if the ARRAY is empty, don't copy it ...
                delete $copy{ $k };
            }
        }
        elsif ( Scalar::Util::blessed( $copy{ $k } ) && $copy{ $k }->roles::DOES('Cor::Parser::AST::Role::HasLocation') ) {
            # dump recursively
            $copy{ $k } = dump_ast( $copy{ $k } );
        }
    }
    return \%copy;
}


1;

__END__

=pod

=cut

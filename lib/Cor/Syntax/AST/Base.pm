package Cor::Syntax::AST::Base;

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators   qw[ :accessors ];

use Scalar::Util 'blessed';

use parent 'UNIVERSAL::Object';

use slots (
    start_location => sub {},
    end_location   => sub {},
);

sub start_location     : ro;
sub end_location       : ro;

sub set_start_location : wo;
sub set_end_location   : wo;

sub has_start_location : predicate;
sub has_end_location   : predicate;

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
        elsif ( blessed $copy{ $k } && $copy{ $k }->isa('Cor::Syntax::AST::Location') ) {
            delete $copy{ $k };
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
        elsif ( blessed $copy{ $k } && $copy{ $k }->isa('Cor::Syntax::AST::Base') ) {
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

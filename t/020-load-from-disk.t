#!perl

use v5.24;
use warnings;
use experimental qw[ postderef ];

use Test::More;
use Test::Differences;
use Data::Dumper;

use roles ();

use lib './t/lib';

BEGIN {
    use_ok('Cor');
}

my @pmc_files_to_delete;

subtest '... compiles all the classes together properly' => sub {
    ok((push @pmc_files_to_delete => Cor::build( 'Eq' )),           '... loaded the Eq class with Cor');
    ok((push @pmc_files_to_delete => Cor::build( 'Printable' )),    '... loaded the Printable class with Cor');
    ok((push @pmc_files_to_delete => Cor::build( 'Comparable' )),   '... loaded the Comparable class with Cor');
    ok((push @pmc_files_to_delete => Cor::build( 'Currency::US' )), '... loaded the Currency::US class with Cor');
};

subtest '... does the compiled classes work together properly' => sub {

    require_ok('Currency::US');

    my $dollar = Currency::US->new( amount => 10 );
    ok($dollar->isa( 'Currency::US' ), '... the dollar is a Currency::US instance');
    ok($dollar->roles::DOES( 'Eq' ), '... the dollar does the Eq role');
    ok($dollar->roles::DOES( 'Comparable' ), '... the dollar does the Comparable role');
    ok($dollar->roles::DOES( 'Printable' ), '... the dollar does the Printable role');

    can_ok($dollar, 'equal_to');
    can_ok($dollar, 'not_equal_to');

    can_ok($dollar, 'greater_than');
    can_ok($dollar, 'greater_than_or_equal_to');
    can_ok($dollar, 'less_than');
    can_ok($dollar, 'less_than_or_equal_to');

    can_ok($dollar, 'compare');
    can_ok($dollar, 'to_string');

    is($dollar->to_string, '$10.00 USD', '... got the right to_string value');

    ok($dollar->equal_to( $dollar ), '... we are equal to ourselves');
    ok(!$dollar->not_equal_to( $dollar ), '... we are not not equal to ourselves');

    ok(Currency::US->new( amount => 20 )->greater_than( $dollar ), '... 20 is greater than 10');
    ok(!Currency::US->new( amount => 2 )->greater_than( $dollar ), '... 2 is not greater than 10');

    ok(!Currency::US->new( amount => 10 )->greater_than( $dollar ), '... 10 is not greater than 10');
    ok(Currency::US->new( amount => 10 )->greater_than_or_equal_to( $dollar ), '... 10 is greater than or equal to 10');

};

unlink $_ foreach @pmc_files_to_delete;

done_testing;

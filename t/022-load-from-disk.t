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
    ok((push @pmc_files_to_delete => Cor::build( 'Finance::BankAccount' )),    '... loaded the Finance::BankAccount class with Cor');
    ok((push @pmc_files_to_delete => Cor::build( 'Finance::CheckingAccount' )), '... loaded the Finance::CheckingAccount class with Cor');
};

subtest '... does the compiled classes work together properly' => sub {

    require_ok('Finance::BankAccount');
    require_ok('Finance::CheckingAccount');

    my $savings = Finance::BankAccount->new( balance => 250 );
    isa_ok($savings, 'Finance::BankAccount' );

    is($savings->balance, 250, '... got the savings balance we expected');

    $savings->withdraw( 50 );
    is($savings->balance, 200, '... got the savings balance we expected');

    $savings->deposit( 150 );
    is($savings->balance, 350, '... got the savings balance we expected');

    my $checking = Finance::CheckingAccount->new(
        overdraft_account => $savings,
    );
    isa_ok($checking, 'Finance::CheckingAccount');
    isa_ok($checking, 'Finance::BankAccount');

    ok(!$checking->can('withdraw_from_overdraft'), '... we do not have a `withdraw_from_overdraft` method available');

    is($checking->balance, 0, '... got the checking balance we expected');

    $checking->deposit( 100 );
    is($checking->balance, 100, '... got the checking balance we expected');
    is($checking->overdraft_account, $savings, '... got the right overdraft account');

    $checking->withdraw( 50 );
    is($checking->balance, 50, '... got the checking balance we expected');
    is($savings->balance, 350, '... got the savings balance we expected');

    $checking->withdraw( 200 );
    is($checking->balance, 0, '... got the checking balance we expected');
    is($savings->balance, 200, '... got the savings balance we expected');

};

foreach (@pmc_files_to_delete) {
    #diag "Deleting $_";
    unlink $_;
}

done_testing;

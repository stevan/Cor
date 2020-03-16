#!perl

use v5.24;
use warnings;
use experimental qw[ postderef ];

use Test::More;
use Test::Differences;
use Data::Dumper;

use roles ();

BEGIN {
    use_ok('Cor');
}

my $ROOT = './t/lib/';

my %RESULTS;

subtest '... compiles all the classes together properly' => sub {
    @{ $RESULTS{BANK_ACCOUNT}    }{qw[ src matches ]} = Cor::load_file( $ROOT . "Finance/BankAccount.pm" );
    @{ $RESULTS{CHECKING_ACCOUNT}}{qw[ src matches ]} = Cor::load_file( $ROOT . "Finance/CheckingAccount.pm" );

    ok($RESULTS{BANK_ACCOUNT}->{src}, '... got source for BANK_ACCOUNT');
    #warn $RESULTS{BANK_ACCOUNT}->{src};
    isa_ok($RESULTS{BANK_ACCOUNT}->{matches}->[0], 'Cor::Parser::AST::Class');

    ok($RESULTS{CHECKING_ACCOUNT}->{src}, '... got source for CHECKING_ACCOUNT');
    #warn $RESULTS{CHECKING_ACCOUNT}->{src};
    isa_ok($RESULTS{CHECKING_ACCOUNT}->{matches}->[0], 'Cor::Parser::AST::Class');

};

subtest '... does the compiled classes work together properly' => sub {

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

done_testing;

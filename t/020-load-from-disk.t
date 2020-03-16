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
    @{ $RESULTS{EQ}          }{qw[ src matches ]} = Cor::load_file( $ROOT . "Eq.pm" );
    @{ $RESULTS{PRINTABLE}   }{qw[ src matches ]} = Cor::load_file( $ROOT . "Printable.pm" );
    @{ $RESULTS{COMPARABLE}  }{qw[ src matches ]} = Cor::load_file( $ROOT . "Comparable.pm" );
    @{ $RESULTS{CURRENCY_US} }{qw[ src matches ]} = Cor::load_file( $ROOT . "Currency/US.pm" );

    ok($RESULTS{EQ}->{src}, '... got source for EQ');
    #warn $RESULTS{EQ}->_src;
    isa_ok($RESULTS{EQ}->{matches}->[0], 'Cor::Parser::AST::Role');

    ok($RESULTS{PRINTABLE}->{src}, '... got source for PRINTABLE');
    #warn $RESULTS{PRINTABLE}->{src};
    isa_ok($RESULTS{PRINTABLE}->{matches}->[0], 'Cor::Parser::AST::Role');

    ok($RESULTS{COMPARABLE}->{src}, '... got source for COMPARABLE');
    #warn $RESULTS{COMPARABLE}->{src};
    isa_ok($RESULTS{COMPARABLE}->{matches}->[0], 'Cor::Parser::AST::Role');

    ok($RESULTS{CURRENCY_US}->{src}, '... got source for CURRENCY_US');
    #warn $RESULTS{CURRENCY_US}->{src};
    isa_ok($RESULTS{CURRENCY_US}->{matches}->[0], 'Cor::Parser::AST::Class');
};

subtest '... does the compiled classes work together properly' => sub {

    my $dollar = Currency::US->new( amount => 10 );
    ok($dollar->isa( 'Currency::US' ), '... the dollar is a Currency::US instance');
    ok($dollar->isa( 'UNIVERSAL::Object::Immutable' ), '... the dollar is a Currency::US instance');
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

done_testing;

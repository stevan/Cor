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

    foreach my $pkg ( qw[ Eq Printable Comparable Currency::US ] ) {
        @{ $RESULTS{ $pkg } }{qw[ src matches ]} = Cor::load( $pkg, $ROOT );
    }

    ok($RESULTS{'Eq'}->{src}, '... got source for Eq');
    #warn $RESULTS{'Eq'}->_src;
    isa_ok($RESULTS{'Eq'}->{matches}->[0], 'Cor::Parser::AST::Role');

    ok($RESULTS{'Printable'}->{src}, '... got source for Printable');
    #warn $RESULTS{'Printable'}->{src};
    isa_ok($RESULTS{'Printable'}->{matches}->[0], 'Cor::Parser::AST::Role');

    ok($RESULTS{'Comparable'}->{src}, '... got source for Comparable');
    #warn $RESULTS{'Comparable'}->{src};
    isa_ok($RESULTS{'Comparable'}->{matches}->[0], 'Cor::Parser::AST::Role');

    ok($RESULTS{'Currency::US'}->{src}, '... got source for Currency::US');
    #warn $RESULTS{Currency::US}->{src};
    isa_ok($RESULTS{'Currency::US'}->{matches}->[0], 'Cor::Parser::AST::Class');
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

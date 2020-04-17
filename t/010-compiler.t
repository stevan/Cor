#!perl

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

use Test::More;
use Test::Differences;
use Data::Dumper;

BEGIN {
    use_ok('Cor');
    use_ok('Cor::Evaluator');
}


my $GOT;
subtest '... verify the AST object' => sub {

    my $original = join '' => <DATA>;
    my $doc      = Cor::Parser::parse( $original );

    #warn Dumper $doc;

    my $compiler = Cor::Compiler->new( doc => $doc );

    $GOT = $compiler->compile;

    my ($ast) = $doc->asts->@*;
    isa_ok($ast, 'Cor::Parser::AST::Class');
    is($ast->name, 'Point', '... the AST is for the Point class');
};

my $EXPECTED = 'use Scalar::Util;
package Geometry::Point 0.01 {
use v5.24;
use warnings;
use experimental qw[ signatures ];
use MOP;
use roles ();
use UNIVERSAL::Object;
# superclasses
our @ISA; BEGIN { @ISA = qw[UNIVERSAL::Object] }
# constructor
sub BUILDARGS ($class, %args) {
my %proto;
$proto{q[$x]} = $args{q[x]} if exists $args{q[x]};
$proto{q[$y]} = $args{q[y]} if exists $args{q[y]};
return \%proto;
}
# constants
use constant DEBUG => ($ENV{DEBUG} // 0);
# slots
our %HAS; BEGIN { %HAS = (
    q[$x] => sub { 0 },
    q[$y] => sub { 0 },
) }
# methods
sub x ($self) { $self->{q[$x]} }
sub y ($self) { $self->{q[$y]} }
sub dump ($self) {
        return +{ x => $self->{q[$x]}, y => $self->{q[$y]} };
    }
1;
}';

eq_or_diff($GOT, $EXPECTED, '... simple compiler working');

subtest '... eval and test the compiled output', sub {

    Cor::Evaluator::evaluate( $GOT );

    my $p = Geometry::Point->new( x => 10, y => 20 );
    isa_ok($p, 'Geometry::Point');

    is($p->x, 10, '... got the right value for x');
    is($p->y, 20, '... got the right value for y');

    is_deeply($p->dump, { x => 10, y => 20 }, '... got the right value from dump method');
};

done_testing;

__DATA__

use Scalar::Util;

module Geometry;

class Point v0.01 {

    const DEBUG = $ENV{DEBUG} // 0;

    has $x = 0;
    has $y = 0;

    method x :ro($x);
    method y :ro($y);

    method dump {
        return +{ x => $x, y => $y };
    }
}


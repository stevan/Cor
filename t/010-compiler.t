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
    my $matches  = Cor::Parser::parse( $original );
    my $compiler = Cor::Compiler->new(
        asts   => $matches,
        traits => {
            'ro' => sub ( $meta, $method, $attribute ) {
                return unless $method->isa('Cor::Parser::AST::Method');
                return unless $method->has_attributes;

                $method->set_is_abstract(0);
                $method->set_attributes([ grep $_ ne $attribute, $method->attributes->@* ]);
                $method->set_body(
                    Cor::Parser::ASTBuilder::new_method_body_at(
                        '{ $_[0]->{q['.$attribute->args.']} }',
                        [],
                        -1
                    )
                );
            }
        }
    );

    $GOT = $compiler->compile;

    my ($ast) = $matches->@*;
    isa_ok($ast, 'Cor::Parser::AST::Class');
    is($ast->name, 'Point', '... the AST is for the Point class');
};

my $EXPECTED = 'package Point 0.01 {
use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators qw[ :accessors :constructor ];
use MOP;
use UNIVERSAL::Object;
# superclasses
our @ISA; BEGIN { @ISA = qw[UNIVERSAL::Object] }
# slots
our %HAS; BEGIN { %HAS = (
    q[$_x] => sub { 0 },
    q[$_y] => sub { 0 },
) }
# methods
sub BUILDARGS :strict(x => $_x, y => $_y);
sub x { $_[0]->{q[$_x]} }
sub y { $_[0]->{q[$_y]} }
sub dump {
        return +{ x => $_[0]->{q[$_x]}, y => $_[0]->{q[$_y]} };
    }
1;
}';

eq_or_diff($GOT, $EXPECTED, '... simple compiler working');

subtest '... eval and test the compiled output', sub {

    Cor::Evaluator::evaluate( $GOT );

    my $p = Point->new( x => 10, y => 20 );
    isa_ok($p, 'Point');

    is($p->x, 10, '... got the right value for x');
    is($p->y, 20, '... got the right value for y');

    is_deeply($p->dump, { x => 10, y => 20 }, '... got the right value from dump method');
};

done_testing;

__DATA__

class Point v0.01 {

    has $_x = 0;
    has $_y = 0;

    method BUILDARGS :strict(x => $_x, y => $_y);

    method x :ro($_x);
    method y :ro($_y);

    method dump {
        return +{ x => $_x, y => $_y };
    }
}


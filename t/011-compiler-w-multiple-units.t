#!perl

use v5.24;
use warnings;
use experimental qw[ postderef ];

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

    {
        my $ast = $matches->[0];
        isa_ok($ast, 'Cor::Parser::AST::Role');
        is($ast->name, 'Dumpable', '... the AST is for the Dumpable role');
    }
    {
        my $ast = $matches->[1];
        isa_ok($ast, 'Cor::Parser::AST::Class');
        is($ast->name, 'Point', '... the AST is for the Point class');

        #warn Dumper $ast->dump;
    }
    {
        my $ast = $matches->[2];
        isa_ok($ast, 'Cor::Parser::AST::Class');
        is($ast->name, 'Point3D', '... the AST is for the Point3D class');
    }

    my $compiler = Cor::Compiler->new( asts => $matches );

    $GOT = $compiler->compile;

    #warn $GOT;
};

subtest '... eval and test the compiled output', sub {

    Cor::Evaluator::evaluate( $GOT );

    my $p = Point3D->new( x => 10, y => 20, z => 5 );
    isa_ok($p, 'Point3D');
    isa_ok($p, 'Point');

    ok(!$p->can('dump_x'), '... the object has no dump_x method');
    ok(!$p->can('dump_y'), '... the object has no dump_y method');

    is($p->x, 10, '... got the right value for x');
    is($p->y, 20, '... got the right value for y');
    is($p->z, 5,  '... got the right value for z');

    ok($p->has_x, '... has a value for x');
    ok($p->has_y, '... has a value for y');
    ok($p->has_z,  '... has a value for z');

    $p->set_x(undef);
    $p->set_y(undef);
    $p->set_z(undef);

    ok(!$p->has_x, '... has a value for x');
    ok(!$p->has_y, '... has a value for y');
    ok(!$p->has_z,  '... has a value for z');

    $p->set_x(100);
    $p->set_y(200);
    $p->set_z(50);

    is($p->x, 100, '... got the right value for x');
    is($p->y, 200, '... got the right value for y');
    is($p->z, 50,  '... got the right value for z');

    is_deeply($p->dump, { x => 100, y => 200, z => 50 }, '... got the right value from dump method');
};

done_testing;

__DATA__

role Dumpable {
    # can include comments ...
    method dump;
}

class Point does Dumpable {

    has $_x :reader(x) :writer(set_x) :predicate(has_x) = 0;
    has $_y :reader(y) :writer(set_y) :predicate(has_y) = 0;

    method BUILDARGS :strict(x => $_x, y => $_y);

    method dump_x : private { 0+$_x }
    method dump_y : private { 0+$_y }

    method dump ($self) { +{ x => $self->dump_x(), y => $self->dump_y() } }

    method to_JSON ($self) { $self->dump() }
}

class Point3D isa Point {

    has $_z :reader(z) = 0;

    method BUILDARGS :strict(
        x => super(x),
        y => super(y),
        z => $_z
    );

    method set_z :writer($_z);
    method has_z :predicate($_z);

    method dump_z : private { 0+$_z }

    method dump ($self) {
        +{ $self->next::method->%*, z => $self->dump_z() }
    }

}

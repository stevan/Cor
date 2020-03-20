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

    is($p->x, 10, '... got the right value for x');
    is($p->y, 20, '... got the right value for y');
    is($p->z, 5,  '... got the right value for z');

    is_deeply($p->dump, { x => 10, y => 20, z => 5 }, '... got the right value from dump method');
};

done_testing;

__DATA__

role Dumpable {
    # can include comments ...
    method dump;
}

class Point does Dumpable {

    has $_x = 0;
    has $_y = 0;

    method BUILDARGS :strict(x => $_x, y => $_y);

    method x :ro($_x);
    method y :ro($_y);

    method dump { +{ x => $_x, y => $_y } }
}

class Point3D isa Point {

    has $_z = 0;

    method BUILDARGS :strict(
        x => super(x),
        y => super(y),
        z => $_z
    );

    method z :ro($_z);

    method dump ($self) {
        +{ $self->next::method->%*, z => $_z }
    }

}

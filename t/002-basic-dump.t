#!perl

use v5.24;
use warnings;
use experimental qw[ postderef ];

use Test::More;
use Test::Differences;
use Data::Dumper;

BEGIN {
    use_ok('Cor');
    use_ok('Cor::Parser');
    use_ok('Cor::Parser::ASTDumper');
}

my $src = join '' => <DATA>;

my $doc = Cor::Parser::parse( $src );

eq_or_diff(
    $doc->use_statements,
    [
        'use v5.24;',
        'use Scalar::Utils;',
        'use List::Utils;',
        'use Other::Module;',
    ],
    '... got the expected use statements'
);

my ($dumpable, $plane, $point, $point_3d) = $doc->asts->@*;

eq_or_diff(
    Cor::Parser::ASTDumper::dump_AST( $dumpable ),
    {
        name    => 'Dumpable',
        version => 'v0.01',
        methods => [ { name => 'dump', is_abstract => 1 } ],
    },
    '... the Dumpable role looks correct'
);

eq_or_diff(
    Cor::Parser::ASTDumper::dump_AST( $plane ),
    {
        'name'         => 'Plane',
        'version'      => 'v0.01',
        'module'       => { 'name' => 'Geometry' },
        'superclasses' => [ { 'name' => 'UNIVERSAL::Object' } ],
        'slots'        => [
            {
                'name'       => '$_space',
                'type'       => { name => 'ArrayRef[ ArrayRef[Point] ]' },
            },
        ]
    },
    '... Plane class looks correct'
);

eq_or_diff(
    Cor::Parser::ASTDumper::dump_AST( $point ),
    {
        'name'         => 'Point',
        'version'      => 'v0.01',
        'module'       => { 'name' => 'Geometry' },
        'superclasses' => [ { 'name' => 'UNIVERSAL::Object' } ],
        'roles'        => [ { 'name' => 'Dumpable' } ],
        'constants'    => [ { name => 'DEBUG', value => '$ENV{POINT_DEBUG} // 0' } ],
        'slots'        => [
            {
                'name'       => '$_x',
                'attributes' => [ { name => 'optional' } ],
                'default'    => '0',
                'type'       => { name => 'Int' },
            },
            {
                'name'       => '$_y',
                'attributes' => [ { name => 'optional' } ],
                'default'    => '0',
                'type'       => { name => 'Int' },
            },
        ],
        'methods' => [
            {
                'name'        => 'x',
                'attributes'  => [
                    {
                        name => 'ro',
                        args => '$_x',
                    }
                ],
                'is_abstract' => 1,
            },
            {
                'name'        => 'y',
                'attributes'  => [
                    {
                        name => 'ro',
                        args => '$_y',
                    }
                ],
                'is_abstract' => 1,
            },
            {
                'name' => 'dump',
                'body' => {
                    source         => '{ +{ x => $_x, y => $_y } }',
                    slot_locations => [
                        { match => '$_x', start => 10 },
                        { match => '$_y', start => 20 },
                    ]
                },
            }
        ],
    },
    '... Point class looks correct'
);

eq_or_diff(
    Cor::Parser::ASTDumper::dump_AST( $point_3d ),
    {
        'name'         => 'Point3D',
        'version'      => 'v0.01',
        'module'       => { 'name' => 'Geometry' },
        'superclasses' => [ { 'name' => 'Point' } ],
        'slots'        => [
            {
                'name'       => '$_z',
                'attributes' => [ { name => 'optional' } ],
                'default'    => '0',
                'type'       => { name => 'Int' },
            },
        ],
        'methods'      => [
            {
                'name'        => 'z',
                'attributes'  => [
                    {
                        name => 'ro',
                        args => '$_z',
                    }
                ],
                'is_abstract' => 1,

            },
            {
                'name'      => 'dump',
                'signature' => { arguments => [ '$self' ] },
                'body'      => {
                    source => '{
        +{ $self->next::method->%*, z => $_z }
    }',
                    slot_locations => [
                        { match => '$_z', start => 43 }
                    ],
                    self_call_locations => [
                        { match => 'next::method', start => 20 }
                    ],
                    class_usage_locations => [
                        { match => 'next::method', start => 20 }
                    ],
                }
            }
        ],
    },
    '... Point3D class looks correct'
);

done_testing;

__DATA__

use v5.24;
use Scalar::Utils;

role Dumpable v0.01 {
    # can include comments ...
    method dump;
}

module Geometry;

use List::Utils;

class Plane v0.01 isa UNIVERSAL::Object {

    has ArrayRef[ ArrayRef[Point] ] $_space;

}

class Point v0.01 isa UNIVERSAL::Object does Dumpable {

    const DEBUG = $ENV{POINT_DEBUG} // 0;

    has Int $_x :optional = 0;
    has Int $_y :optional = 0;

    method x :ro($_x);
    method y :ro($_y);

    method dump { +{ x => $_x, y => $_y } }
}

use Other::Module;

class Point3D v0.01 isa Point {

    has Int $_z :optional = 0;

    method z :ro($_z);

    method dump ($self) {
        +{ $self->next::method->%*, z => $_z }
    }

}

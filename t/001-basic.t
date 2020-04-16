#!perl

use v5.24;
use warnings;
use experimental qw[ postderef ];

use Test::More;
use Data::Dumper;

BEGIN {
    use_ok('Cor');
    use_ok('Cor::Parser');
    use_ok('Cor::Parser::ASTDumper');
}

my $src = join '' => <DATA>;

my $doc = Cor::Parser::parse( $src );

#warn Dumper $doc;

is_deeply(
    $doc->use_statements,
    [
        'use v5.24;',
        'use Scalar::Utils;',
        'use List::Utils;',
        'use Other::Module;',
    ],
    '... got the expected use statements'
);

my ($dumpable, $point, $point_3d) = $doc->asts->@*;

# role definition
is($dumpable->start_location->char_at, 68, '... got the right start char number');
is($dumpable->end_location->char_at, 139, '... got the right end char number');

# method definition
is($dumpable->methods->[0]->start_location->char_at, 125, '... got the right start char number');
is($dumpable->methods->[0]->end_location->char_at, 136, '... got the right end char number');

is_deeply(
    Cor::Parser::ASTDumper::dump_AST( $dumpable ),
    {
        name    => 'Dumpable',
        version => 'v0.01',
        methods => [ { name => 'dump', is_abstract => 1 } ],
    },
    '... the Dumpable role looks correct'
);

# class definition
is($point->start_location->char_at, 141, '... got the right start char number');
is($point->end_location->char_at, 325, '... got the right end char number');

# superclass declaration
is($point->superclasses->[0]->start_location->char_at, 163, '... got the right start char number');
is($point->superclasses->[0]->end_location->char_at, 180, '... got the right end char number');

# role declaration
is($point->roles->[0]->start_location->char_at, 186, '... got the right start char number');
is($point->roles->[0]->end_location->char_at, 194, '... got the right end char number');

is($point->slots->[0]->identifier, '_x', '... got the right identifier for the slot');
is($point->slots->[1]->identifier, '_y', '... got the right identifier for the slot');

# slot declarations
is($point->slots->[0]->start_location->char_at, 202, '... got the right start char number');
is($point->slots->[0]->end_location->char_at, 213, '... got the right end char number');
is($point->slots->[1]->start_location->char_at, 219, '... got the right start char number');
is($point->slots->[1]->end_location->char_at, 230, '... got the right end char number');

# method declarations
is($point->methods->[0]->start_location->char_at, 237, '... got the right start char number');
is($point->methods->[0]->end_location->char_at, 254, '... got the right end char number');

is($point->methods->[1]->start_location->char_at, 260, '... got the right start char number');
is($point->methods->[1]->end_location->char_at, 277, '... got the right end char number');

is($point->methods->[2]->start_location->char_at, 284, '... got the right start char number');
is($point->methods->[2]->end_location->char_at, 323, '... got the right end char number');

is($point->methods->[2]->body->start_location->char_at, 296, '... got the right start char number');
is($point->methods->[2]->body->end_location->char_at, 323, '... got the right end char number');

is_deeply(
    Cor::Parser::ASTDumper::dump_AST( $point ),
    {
        'name'         => 'Point',
        'version'      => 'v0.01',
        'superclasses' => [ { 'name' => 'UNIVERSAL::Object' } ],
        'roles'        => [ { 'name' => 'Dumpable' } ],
        'slots'        => [
            { 'name' => '$_x', 'default' => '0' },
            { 'default' => '0', 'name' => '$_y' }
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

# class declaration
is($point_3d->start_location->char_at, 327, '... got the right start char number');
is($point_3d->end_location->char_at, 483, '... got the right end char number');

# superclass declaration
is($point_3d->superclasses->[0]->start_location->char_at, 351, '... got the right start char number');
is($point_3d->superclasses->[0]->end_location->char_at, 356, '... got the right end char number');

is($point_3d->slots->[0]->identifier, '_z', '... got the right identifier for the slot');

# slot declarations
is($point_3d->slots->[0]->start_location->char_at, 364, '... got the right start char number');
is($point_3d->slots->[0]->end_location->char_at, 375, '... got the right end char number');

# method declarations
is($point_3d->methods->[0]->start_location->char_at, 382, '... got the right start char number');
is($point_3d->methods->[0]->end_location->char_at, 399, '... got the right end char number');

is($point_3d->methods->[1]->start_location->char_at, 406, '... got the right start char number');
is($point_3d->methods->[1]->end_location->char_at, 480, '... got the right end char number');

is($point_3d->methods->[1]->body->start_location->char_at, 426, '... got the right start char number');
is($point_3d->methods->[1]->body->end_location->char_at, 480, '... got the right end char number');

is_deeply(
    Cor::Parser::ASTDumper::dump_AST( $point_3d ),
    {
        'name'         => 'Point3D',
        'version'      => 'v0.01',
        'superclasses' => [ { 'name' => 'Point' } ],
        'slots'        => [ { 'default' => '0', 'name' => '$_z' } ],
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
                    ]
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
use List::Utils;
use Other::Module;

role Dumpable v0.01 {
    # can include comments ...
    method dump;
}

class Point v0.01 isa UNIVERSAL::Object does Dumpable {

    has $_x = 0;
    has $_y = 0;

    method x :ro($_x);
    method y :ro($_y);

    method dump { +{ x => $_x, y => $_y } }
}

class Point3D v0.01 isa Point {

    has $_z = 0;

    method z :ro($_z);

    method dump ($self) {
        +{ $self->next::method->%*, z => $_z }
    }

}

#!perl

use v5.24;
use warnings;
use experimental qw[ postderef ];

use Test::More;
use Data::Dumper;

BEGIN {
    use_ok('Cor');
    use_ok('Cor::Parser');
}

my $src = join '' => <DATA>;

my $matches = Cor::Parser::parse( $src );

my ($dumpable, $point, $point_3d) = $matches->@*;

# role definition
is($dumpable->start_location->char_at, 68, '... got the right start char number');
is($dumpable->end_location->char_at, 138, '... got the right end char number');

# method definition
is($dumpable->methods->[0]->start_location->char_at, 125, '... got the right start char number');
is($dumpable->methods->[0]->end_location->char_at, 136, '... got the right end char number');

is_deeply(
    $dumpable->dump,
    {
        name    => 'Dumpable',
        version => 'v0.01',
        roles   => [],
        slots   => [],
        methods => [ { name => 'dump', is_abstract => 1 } ],
    },
    '... the Dumpable role looks correct'
);

# class definition
is($point->start_location->char_at, 141, '... got the right start char number');
is($point->end_location->char_at, 322, '... got the right end char number');

# superclass declaration
is($point->superclasses->[0]->start_location->char_at, 163, '... got the right start char number');
is($point->superclasses->[0]->end_location->char_at, 180, '... got the right end char number');

# role declaration
is($point->roles->[0]->start_location->char_at, 186, '... got the right start char number');
is($point->roles->[0]->end_location->char_at, 194, '... got the right end char number');

# slot declarations
is($point->slots->[0]->start_location->char_at, 202, '... got the right start char number');
is($point->slots->[0]->end_location->char_at, 213, '... got the right end char number');
is($point->slots->[1]->start_location->char_at, 219, '... got the right start char number');
is($point->slots->[1]->end_location->char_at, 230, '... got the right end char number');

# method declarations
is($point->methods->[0]->start_location->char_at, 237, '... got the right start char number');
is($point->methods->[0]->end_location->char_at, 253, '... got the right end char number');
is($point->methods->[1]->start_location->char_at, 259, '... got the right start char number');
is($point->methods->[1]->end_location->char_at, 275, '... got the right end char number');
is($point->methods->[2]->start_location->char_at, 282, '... got the right start char number');
is($point->methods->[2]->end_location->char_at, 321, '... got the right end char number');

is_deeply(
    $point->dump,
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
                'attributes'  => ':ro(_x)',
                'is_abstract' => 1,
            },
            {
                'name'        => 'y',
                'attributes'  => ':ro(_y)',
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
is($point_3d->start_location->char_at, 325, '... got the right start char number');
is($point_3d->end_location->char_at, 479, '... got the right end char number');

# superclass declaration
is($point_3d->superclasses->[0]->start_location->char_at, 349, '... got the right start char number');
is($point_3d->superclasses->[0]->end_location->char_at, 354, '... got the right end char number');

# slot declarations
is($point_3d->slots->[0]->start_location->char_at, 362, '... got the right start char number');
is($point_3d->slots->[0]->end_location->char_at, 373, '... got the right end char number');

# method declarations
is($point_3d->methods->[0]->start_location->char_at, 380, '... got the right start char number');
is($point_3d->methods->[0]->end_location->char_at, 396, '... got the right end char number');
is($point_3d->methods->[1]->start_location->char_at, 403, '... got the right start char number');
is($point_3d->methods->[1]->end_location->char_at, 477, '... got the right end char number');

is_deeply(
    $point_3d->dump,
    {
        'name'         => 'Point3D',
        'version'      => 'v0.01',
        'superclasses' => [ { 'name' => 'Point' } ],
        'roles'        => [],
        'slots'        => [ { 'default' => '0', 'name' => '$_z' } ],
        'methods'      => [
            {
                'name'        => 'z',
                'attributes'  => ':ro(_z)',
                'is_abstract' => 1,

            },
            {
                'name'      => 'dump',
                'signature' => '($self)',
                'body'      => {
                    source => '{
        +{ $self->next::method->%*, z => $_z }
    }',
                    slot_locations => [
                        { match => '$_z', start => 43 }
                    ]
                }
            }
        ],
    },
    '... Point3D class looks correct'
);

done_testing;

__DATA__

package Something {
    # ignore stuff that is not relevant ...
}

role Dumpable v0.01 {
    # can include comments ...
    method dump;
}

class Point v0.01 isa UNIVERSAL::Object does Dumpable {

    has $_x = 0;
    has $_y = 0;

    method x :ro(_x);
    method y :ro(_y);

    method dump { +{ x => $_x, y => $_y } }
}

class Point3D v0.01 isa Point {

    has $_z = 0;

    method z :ro(_z);

    method dump ($self) {
        +{ $self->next::method->%*, z => $_z }
    }

}

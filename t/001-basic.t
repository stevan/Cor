#!perl

use v5.24;
use warnings;

use Test::More;
use Data::Dumper;

BEGIN {
    use_ok('Cor');
    use_ok('Cor::Syntax');
}

my $src = join '' => <DATA>;

my ($dumpable, $point, $point_3d) = Cor::Syntax::parse( $src );

is($dumpable->location->start, 68, '... got the right start positon');

is($dumpable->methods->[0]->location->start, 125, '... got the right start location');

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

is($point->location->start, 141, '... got the right start positon');

is($point->superclasses->[0]->location->start, 163, '... got the right start location');
is($point->roles->[0]->location->start, 186, '... got the right start location');

is($point->slots->[0]->location->start, 202, '... got the right start location');
is($point->slots->[1]->location->start, 219, '... got the right start location');

is($point->methods->[0]->location->start, 237, '... got the right start location');
is($point->methods->[1]->location->start, 259, '... got the right start location');
is($point->methods->[2]->location->start, 282, '... got the right start location');

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
                'body' => '{ +{ x => $_x, y => $_y } }',
            }
        ],
    },
    '... Point class looks correct'
);

is($point_3d->location->start, 325, '... got the right start positon');

is($point_3d->superclasses->[0]->location->start, 349, '... got the right start location');

is($point_3d->slots->[0]->location->start, 362, '... got the right start location');

is($point_3d->methods->[0]->location->start, 380, '... got the right start location');
is($point_3d->methods->[1]->location->start, 403, '... got the right start location');

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
                'body'      => '{ +{ $self->next::method->%*, z => $_z } }',
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

    method dump ($self) { +{ $self->next::method->%*, z => $_z } }

}

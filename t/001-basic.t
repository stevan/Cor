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

# role definition

is($dumpable->start_location->char_number, 68, '... got the right start char number');
is($dumpable->start_location->line_number, 6, '... got the right start line number');

is($dumpable->end_location->char_number, 138, '... got the right end char number');
is($dumpable->end_location->line_number, 9, '... got the right end line number');

# method definition

is($dumpable->methods->[0]->start_location->char_number, 125, '... got the right start char number');
is($dumpable->methods->[0]->start_location->line_number, 8, '... got the right start line number');

is($dumpable->methods->[0]->end_location->char_number, 136, '... got the right end char number');
is($dumpable->methods->[0]->end_location->line_number, 8, '... got the right end line number');

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

is($point->start_location->char_number, 141, '... got the right start char number');
is($point->start_location->line_number, 11, '... got the right start line number');

is($point->end_location->char_number, 322, '... got the right end char number');
is($point->end_location->line_number, 20, '... got the right end line number');

# superclass declaration

is($point->superclasses->[0]->start_location->char_number, 163, '... got the right start char number');
is($point->superclasses->[0]->start_location->line_number, 11, '... got the right start line number');

is($point->superclasses->[0]->end_location->char_number, 180, '... got the right end char number');
is($point->superclasses->[0]->end_location->line_number, 11, '... got the right end line number');

# role declaration

is($point->roles->[0]->start_location->char_number, 186, '... got the right start char number');
is($point->roles->[0]->start_location->line_number, 11, '... got the right start line number');

is($point->roles->[0]->end_location->char_number, 194, '... got the right end char number');
is($point->roles->[0]->end_location->line_number, 11, '... got the right end line number');

# slot declarations

is($point->slots->[0]->start_location->char_number, 202, '... got the right start char number');
is($point->slots->[0]->start_location->line_number, 13, '... got the right start line number');

is($point->slots->[0]->end_location->char_number, 213, '... got the right end char number');
is($point->slots->[0]->end_location->line_number, 13, '... got the right end line number');

is($point->slots->[1]->start_location->char_number, 219, '... got the right start char number');
is($point->slots->[1]->start_location->line_number, 14, '... got the right start line number');

is($point->slots->[1]->end_location->char_number, 230, '... got the right end char number');
is($point->slots->[1]->end_location->line_number, 14, '... got the right end line number');

# method declarations

is($point->methods->[0]->start_location->char_number, 237, '... got the right start char number');
is($point->methods->[0]->start_location->line_number, 16, '... got the right start line number');

is($point->methods->[0]->end_location->char_number, 253, '... got the right end char number');
is($point->methods->[0]->end_location->line_number, 16, '... got the right end line number');

is($point->methods->[1]->start_location->char_number, 259, '... got the right start char number');
is($point->methods->[1]->start_location->line_number, 17, '... got the right start line number');

is($point->methods->[1]->end_location->char_number, 275, '... got the right end char number');
is($point->methods->[1]->end_location->line_number, 17, '... got the right end line number');

is($point->methods->[2]->start_location->char_number, 282, '... got the right start char number');
is($point->methods->[2]->start_location->line_number, 19, '... got the right start line number');

is($point->methods->[2]->end_location->char_number, 321, '... got the right end char number');
is($point->methods->[2]->end_location->line_number, 19, '... got the right end line number');

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

# class declaration

is($point_3d->start_location->char_number, 325, '... got the right start char number');
is($point_3d->start_location->line_number, 22, '... got the right start line number');

is($point_3d->end_location->char_number, 467, '... got the right end char number');
is($point_3d->end_location->line_number, 30, '... got the right end line number');

# superclass declaration

is($point_3d->superclasses->[0]->start_location->char_number, 349, '... got the right start char number');
is($point_3d->superclasses->[0]->start_location->line_number, 22, '... got the right start line number');

is($point_3d->superclasses->[0]->end_location->char_number, 354, '... got the right end char number');
is($point_3d->superclasses->[0]->end_location->line_number, 22, '... got the right end line number');

# slot declarations

is($point_3d->slots->[0]->start_location->char_number, 362, '... got the right start char number');
is($point_3d->slots->[0]->start_location->line_number, 24, '... got the right start line number');

is($point_3d->slots->[0]->end_location->char_number, 373, '... got the right end char number');
is($point_3d->slots->[0]->end_location->line_number, 24, '... got the right end line number');

# method declarations

is($point_3d->methods->[0]->start_location->char_number, 380, '... got the right start char number');
is($point_3d->methods->[0]->start_location->line_number, 26, '... got the right start line number');

is($point_3d->methods->[0]->end_location->char_number, 396, '... got the right end char number');
is($point_3d->methods->[0]->end_location->line_number, 26, '... got the right end line number');

is($point_3d->methods->[1]->start_location->char_number, 403, '... got the right start char number');
is($point_3d->methods->[1]->start_location->line_number, 28, '... got the right start line number');

is($point_3d->methods->[1]->end_location->char_number, 465, '... got the right end char number');
is($point_3d->methods->[1]->end_location->line_number, 28, '... got the right end line number');

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

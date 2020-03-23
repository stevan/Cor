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

is_deeply(
    $dumpable->dump,
    {
        name    => 'Dumpable',
        version => 'v0.01',
        methods => [ { name => 'dump', is_abstract => 1 } ],
    },
    '... the Dumpable role looks correct'
);

is_deeply(
    $point->dump,
    {
        'name'         => 'Point',
        'version'      => 'v0.01',
        'superclasses' => [ { 'name' => 'UNIVERSAL::Object' } ],
        'roles'        => [ { 'name' => 'Dumpable' } ],
        'slots'        => [
            {
                'name'       => '$_x',
                'attributes' => [ { name => 'optional' } ],
                'default'    => '0',
            },
            {
                'name'       => '$_y',
                'attributes' => [ { name => 'optional' } ],
                'default'    => '0',
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

is_deeply(
    $point_3d->dump,
    {
        'name'         => 'Point3D',
        'version'      => 'v0.01',
        'superclasses' => [ { 'name' => 'Point' } ],
        'slots'        => [
            {
                'name'       => '$_z',
                'attributes' => [ { name => 'optional' } ],
                'default'    => '0',
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

    has $_x :optional = 0;
    has $_y :optional = 0;

    method x :ro($_x);
    method y :ro($_y);

    method dump { +{ x => $_x, y => $_y } }
}

class Point3D v0.01 isa Point {

    has $_z :optional = 0;

    method z :ro($_z);

    method dump ($self) {
        +{ $self->next::method->%*, z => $_z }
    }

}

#!perl

use v5.24;
use warnings;

use Test::More;
use Test::Differences;
use Data::Dumper;

BEGIN {
    use_ok('Cor');
    use_ok('Cor::Syntax');
    use_ok('Cor::Compiler::SimpleCompiler');
}

my $src = join '' => <DATA>;

my $AST;
subtest '... verify the AST object' => sub {
    ($AST) = Cor::Syntax::parse( $src );
    isa_ok($AST, 'Cor::Syntax::AST::Class');
    is($AST->name, 'Point', '... the AST is for the Point class');
};

my $GOT = Cor::Compiler::SimpleCompiler::compile( $AST );

my $EXPECTED = 'package Point 0.01 {
use v5.24;
use warnings;
use experimental qw[ signatures postderef ];
use decorators qw[ :accessors :constructor ];
# superclasses
our @ISA; BEGIN { @ISA = qw[UNIVERSAL::Object] }
# slots
our %HAS; BEGIN { %HAS = (
    q[$_x] => sub { 0 },
    q[$_y] => sub { 0 },
) }
# methods
sub BUILDARGS :strict(x => $_x, y => $_y);
sub x :ro($_x);
sub y :ro($_y);
sub dump ($self) {
        return +{ x => $self->x, y => $self->y };
    }
}';

eq_or_diff($GOT, $EXPECTED, '... simple compiler working');

subtest '... eval and test the compiled output', sub {

    eval $GOT;
    if ( $@ ) {
        warn $@;
    }

    my $p = Point->new( x => 10, y => 20 );
    isa_ok($p, 'Point');

    is($p->x, 10, '... got the right value for x');
    is($p->y, 20, '... got the right value for y');

    is_deeply($p->dump, { x => 10, y => 20 }, '... got the right value from dump method');
};

done_testing;

__DATA__

class Point v0.01 isa UNIVERSAL::Object {

    has $_x = 0;
    has $_y = 0;

    method BUILDARGS :strict(x => $_x, y => $_y);

    method x :ro($_x);
    method y :ro($_y);

    method dump ($self) {
        return +{ x => $self->x, y => $self->y };
    }
}


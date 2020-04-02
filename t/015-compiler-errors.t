#!perl

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

use Test::More;
use Test::Differences;
use Test::Fatal;
use Data::Dumper;

BEGIN {
    use_ok('Cor');
    use_ok('Cor::Parser');
}

subtest '... testing bad perl statements in method' => sub {
    like(
        exception {
            Cor::Parser::parse(q[
                class Foo {
                    method foo {
                        .= $foo;

                        return $foo;
                    }
                }
            ]);
        },
        qr/^unable to parse method body for `foo` in class `Foo`/,
        '... got the expected exception'
    );
};

subtest '... testing bad perl statements in slot default' => sub {
    like(
        exception {
            Cor::Parser::parse(q[
                class Foo {

                    has $foo = .$bar;

                }
            ]);
        },
        qr/^unable to parse slot default for `\$foo` in class `Foo`/,
        '... got the expected exception'
    );
};

subtest '... testing use statements in class/role' => sub {
    like(
        exception {
            Cor::Parser::parse(q[
                class Foo {
                    use Scalar::Util;
                }
            ]);
        },
        qr/^use statements are not allowed inside class\/role declarations/,
        '... got the expected exception'
    );
};

subtest '... testing variables in class/role' => sub {
    like(
        exception {
            Cor::Parser::parse(q[
                class Foo {
                    my $foo;
                }
            ]);
        },
        qr/^my\/state\/our variables are not allowed inside class\/role declarations/,
        '... got the expected exception'
    );

    like(
        exception {
            Cor::Parser::parse(q[
                class Foo {
                    state $foo;
                }
            ]);
        },
        qr/^my\/state\/our variables are not allowed inside class\/role declarations/,
        '... got the expected exception'
    );

    like(
        exception {
            Cor::Parser::parse(q[
                class Foo {
                    our $foo;
                }
            ]);
        },
        qr/^my\/state\/our variables are not allowed inside class\/role declarations/,
        '... got the expected exception'
    );
};

subtest '... testing subroutines in class/role' => sub {
    like(
        exception {
            Cor::Parser::parse(q[
                class Foo {
                    sub bar {}
                }
            ]);
        },
        qr/^Subroutines are not allowed inside class\/role declarations/,
        '... got the expected exception'
    );
};

done_testing;



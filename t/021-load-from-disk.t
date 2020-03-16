#!perl

use v5.24;
use warnings;
use experimental qw[ postderef ];

use Test::More;
use Test::Differences;
use Data::Dumper;

use roles ();

BEGIN {
    use_ok('Cor');
}

my $ROOT = './t/lib/';

my %RESULTS;

subtest '... compiles all the classes together properly' => sub {
    @{ $RESULTS{LINKED_LIST}      }{qw[ src matches ]} = Cor::load_file( $ROOT . "Collections/LinkedList.pm" );
    @{ $RESULTS{LINKED_LIST_NODE} }{qw[ src matches ]} = Cor::load_file( $ROOT . "Collections/LinkedList/Node.pm" );

    ok($RESULTS{LINKED_LIST}->{src}, '... got source for LINKED_LIST');
    #warn $RESULTS{LINKED_LIST}->{src};
    isa_ok($RESULTS{LINKED_LIST}->{matches}->[0], 'Cor::Parser::AST::Class');

    ok($RESULTS{LINKED_LIST_NODE}->{src}, '... got source for LINKED_LIST_NODE');
    #warn $RESULTS{LINKED_LIST_NODE}->{src};
    isa_ok($RESULTS{LINKED_LIST_NODE}->{matches}->[0], 'Cor::Parser::AST::Class');
};

subtest '... does the compiled classes work together properly' => sub {

    my $ll = Collections::LinkedList->new();

    for(0..9) {
        $ll->append(
            Collections::LinkedList::Node->new(value => $_)
        );
    }

    is($ll->head->get_value, 0, '... head is 0');
    is($ll->tail->get_value, 9, '... tail is 9');
    is($ll->count, 10, '... count is 10');

    $ll->prepend(Collections::LinkedList::Node->new(value => -1));
    is($ll->count, 11, '... count is now 11');

    $ll->insert(5, Collections::LinkedList::Node->new(value => 11));
    is($ll->count, 12, '... count is now 12');

    my $node = $ll->remove(8);
    is($ll->count, 11, '... count is 11 again');

    ok(!$node->get_next, '... detached node does not have a next');
    ok(!$node->get_previous, '... detached node does not have a previous');
    is($node->get_value, 6, '... detached node has the right value');
    ok($node->isa('Collections::LinkedList::Node'), '... node is a Collections::LinkedList::Node');

    eval { $ll->remove(99) };
    like($@, qr/^Index \(99\) out of bounds/, '... removing out of range produced error');
    eval { $ll->insert(-1, Collections::LinkedList::Node->new(value => 2)) };
    like($@, qr/^Index \(-1\) out of bounds/, '... inserting out of range produced error');

    is($ll->sum, 49, '... things sum correctly');
};

done_testing;

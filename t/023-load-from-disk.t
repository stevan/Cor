#!perl

use v5.24;
use warnings;
use experimental qw[ postderef ];

use Test::More;
use Test::Differences;
use Data::Dumper;

use roles ();

use lib './t/lib';

BEGIN {
    use_ok('Cor');
}

my @pmc_files_to_delete;

subtest '... compiles all the classes together properly' => sub {
    ok((push @pmc_files_to_delete => Cor::build( 'Data::BinaryTree' )), '... loaded the Data::BinaryTree class with Cor');
};

subtest '... does the compiled classes work together properly' => sub {

    require_ok('Data::BinaryTree');

    my $t = Data::BinaryTree->new;
    ok($t->isa('Data::BinaryTree'), '... this is a BinaryTree object');

    ok(!$t->has_parent, '... this tree has no parent');

    ok(!$t->has_left, '... left node has not been created yet');
    ok(!$t->has_right, '... right node has not been created yet');

    ok($t->left->isa('Data::BinaryTree'), '... left is a Data::BinaryTree object');
    ok($t->right->isa('Data::BinaryTree'), '... right is a Data::BinaryTree object');

    ok($t->has_left, '... left node has now been created');
    ok($t->has_right, '... right node has now been created');

    ok($t->left->has_parent, '... left has a parent');
    is($t->left->parent, $t, '... and it is us');

    ok($t->right->has_parent, '... right has a parent');
    is($t->right->parent, $t, '... and it is us');

};

foreach (@pmc_files_to_delete) {
    #diag "Deleting $_";
    unlink $_;
}

done_testing;

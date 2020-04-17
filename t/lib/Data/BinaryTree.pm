
module Data;

class BinaryTree {

    has $.node   : rw;
    has $.parent : ro : predicate;

    has $!left  : predicate;
    has $!right : predicate;

    method left  { $!left  //= BinaryTree->new( parent => $self ) }
    method right { $!right //= BinaryTree->new( parent => $self ) }
}

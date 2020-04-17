
module Data;

class BinaryTree {

    has $.node   : rw;
    has $.parent : ro : predicate;

    has $!left  : predicate;
    has $!right : predicate;

    method left  { $!left  //= ref($self)->new( parent => $self ) }
    method right { $!right //= ref($self)->new( parent => $self ) }
}

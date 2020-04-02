
class Data::BinaryTree {

    has $!node   : rw;
    has $!parent : ro : predicate;
    has $!left        : predicate : private;
    has $!right       : predicate : private;

    method left  ($self) { $!left  //= ref($self)->new( parent => $self ) }
    method right ($self) { $!right //= ref($self)->new( parent => $self ) }
}

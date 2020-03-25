
class Data::BinaryTree {

    has $!node   : rw;
    has $!parent : ro : predicate;
    has $!left        : predicate;
    has $!right       : predicate;

    method BUILDARGS : strict( parent? => $!parent );

    method left  ($self) { $!left  //= ref($self)->new( parent => $self ) }
    method right ($self) { $!right //= ref($self)->new( parent => $self ) }
}

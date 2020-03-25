
class Data::BinaryTree {

    has $!node   :reader(node)   :writer(set_node);
    has $!parent :reader(parent) :predicate(has_parent);
    has $!left   :predicate(has_left);
    has $!right  :predicate(has_right);

    method BUILDARGS :strict( parent? => $!parent );

    method left  ($self) { $!left  //= ref($self)->new( parent => $self ) }
    method right ($self) { $!right //= ref($self)->new( parent => $self ) }
}

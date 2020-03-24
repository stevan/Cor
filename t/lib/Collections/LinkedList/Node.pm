
class Collections::LinkedList::Node {

    has $!previous :reader(get_previous) :writer(set_previous);
    has $!next     :reader(get_next)     :writer(set_next);
    has $!value    :reader(get_value)    :writer(set_value);

    method BUILDARGS :strict(value => $!value);

    method detach ($self) {
        ($!previous, $!next) = (undef) x 2;
        $self;
    }
}

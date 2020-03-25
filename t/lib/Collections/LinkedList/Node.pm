
class Collections::LinkedList::Node {

    has $!previous;
    has $!next;
    has $!value;

    method BUILDARGS : strict(value => $!value);

    method get_previous : ro($!previous);
    method set_previous : wo($!previous);

    method get_next     : ro($!next);
    method set_next     : wo($!next);

    method get_value    : ro($!value);
    method set_value    : wo($!value);

    method detach ($self) {
        ($!previous, $!next) = (undef) x 2;
        $self;
    }
}

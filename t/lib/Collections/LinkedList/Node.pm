
class Collections::LinkedList::Node {

    has $!previous : private;
    has $!next     : private;
    has $!value;

    method get_previous : ro($!previous);
    method set_previous : wo($!previous);

    method get_next     : ro($!next);
    method set_next     : wo($!next);

    method get_value    : ro($!value);
    method set_value    : wo($!value);

    method detach {
        ($!previous, $!next) = (undef) x 2;
        $self;
    }
}

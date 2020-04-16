
class Collections::LinkedList::Node {

    has $.value;

    has $!previous;
    has $!next;

    method get_value    : ro($.value);
    method set_value    : wo($.value);

    method get_previous : ro($!previous);
    method set_previous : wo($!previous);

    method get_next     : ro($!next);
    method set_next     : wo($!next);

    method detach {
        ($!previous, $!next) = (undef) x 2;
        $self;
    }
}

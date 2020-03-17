
class Collections::LinkedList::Node isa UNIVERSAL::Object {
    has $!previous;
    has $!next;
    has $!value;

    method BUILDARGS :strict(value => $!value);

    method get_previous { $!previous }
    method get_next     { $!next     }
    method get_value    { $!value    }
    method set_previous ($self, $x) { $!previous = $x; }
    method set_next     ($self, $x) { $!next = $x;     }
    method set_value    ($self, $x) { $!value = $x;    }

    method detach ($self) {
        ($!previous, $!next) = (undef) x 2;
        $self;
    }
}

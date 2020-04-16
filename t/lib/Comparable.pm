
role Comparable does Eq {
    method compare;
    method equal_to ($other) {
        $self->compare($other) == 0;
    }

    method greater_than ($other)  {
        $self->compare($other) == 1;
    }

    method less_than  ($other) {
        $self->compare($other) == -1;
    }

    method greater_than_or_equal_to ($other)  {
        $self->greater_than($other) || $self->equal_to($other);
    }

    method less_than_or_equal_to ($other)  {
        $self->less_than($other) || $self->equal_to($other);
    }
}

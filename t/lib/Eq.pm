role Eq {
    method equal_to;

    method not_equal_to ($other) {
        not $self->equal_to($other);
    }
}

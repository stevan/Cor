class Collections::LinkedList {

    has $!head  : private : ro;
    has $!tail  : private : ro;
    has $!count : private : ro = 0;

    method append ($self, $node) {
        unless($!tail) {
            $!tail = $node;
            $!head = $node;
            $!count++;
            return;
        }
        $!tail->set_next($node);
        $node->set_previous($!tail);
        $!tail = $node;
        $!count++;
    }

    method insert ($self, $index, $node) {
        die "Index ($index) out of bounds"
            if $index < 0 or $index > $!count - 1;

        my $tmp = $!head;
        $tmp = $tmp->get_next while($index--);
        $node->set_previous($tmp->get_previous);
        $node->set_next($tmp);
        $tmp->get_previous->set_next($node);
        $tmp->set_previous($node);
        $!count++;
    }

    method remove ($self, $index) {
        die "Index ($index) out of bounds"
            if $index < 0 or $index > $!count - 1;

        my $tmp = $!head;
        $tmp = $tmp->get_next while($index--);
        $tmp->get_previous->set_next($tmp->get_next);
        $tmp->get_next->set_previous($tmp->get_previous);
        $!count--;
        $tmp->detach();
    }

    method prepend ($self, $node) {
        unless($!head) {
            $!tail = $node;
            $!head = $node;
            $!count++;
            return;
        }
        $!head->set_previous($node);
        $node->set_next($!head);
        $!head = $node;
        $!count++;
    }

    method sum ($self) {
        my $sum = 0;
        my $tmp = $!head;
        do { $sum += $tmp->get_value } while($tmp = $tmp->get_next);
        return $sum;
    }
}

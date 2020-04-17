
module Currency;

class USD does Comparable, Printable {

    has $.amount : ro = 0;

    method compare ($other) {
        $.amount <=> $other->amount;
    }

    method to_string {
        sprintf '$%0.2f USD' => $.amount;
    }
}

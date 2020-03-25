
class Currency::US does Comparable does Printable {

    has $!amount : ro = 0;

    method BUILDARGS : strict(amount => $!amount);

    method compare ($self, $other) {
        $!amount <=> $other->amount;
    }

    method to_string {
        sprintf '$%0.2f USD' => $!amount;
    }
}

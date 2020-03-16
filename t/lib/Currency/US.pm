
class Currency::US isa UNIVERSAL::Object::Immutable does Comparable does Printable {

    has $!amount = 0;

    method BUILDARGS :strict(amount => $!amount);

    method amount : ro($!amount);

    method compare ($self, $other) {
        $!amount <=> $other->amount;
    }

    method to_string {
        sprintf '$%0.2f USD' => $!amount;
    }
}

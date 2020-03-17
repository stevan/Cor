class Finance::BankAccount {

    has $!balance = 0;

    method BUILDARGS :strict(balance => $!balance);

    method balance :ro($!balance);

    method deposit ($elf, $amount) { $!balance += $amount }

    method withdraw ($self, $amount) {
        ($!balance >= $amount)
            || die "Account overdrawn";
        $!balance -= $amount;
    }
}

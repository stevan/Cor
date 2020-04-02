class Finance::BankAccount {

    has $!balance : ro = 0;

    method deposit ($elf, $amount) { $!balance += $amount }

    method withdraw ($self, $amount) {
        ($!balance >= $amount)
            || die "Account overdrawn";
        $!balance -= $amount;
    }
}

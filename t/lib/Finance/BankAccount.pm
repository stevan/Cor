class Finance::BankAccount {

    has $.balance : ro = 0;

    method deposit ($amount) { $.balance += $amount }

    method withdraw ($amount) {
        ($.balance >= $amount)
            || die "Account overdrawn";
        $.balance -= $amount;
    }
}

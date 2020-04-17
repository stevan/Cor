
module Finance;

class CheckingAccount isa BankAccount {

    has $.overdraft_account : ro;

    method withdraw ($amount) {

        my $overdraft_amount = $amount - $self->balance;

        if ( $.overdraft_account && $overdraft_amount > 0 ) {
            $self->withdraw_from_overdraft( $overdraft_amount );
        }

        $self->next::method( $amount );
    }

    method withdraw_from_overdraft : private ($amount) {
        $.overdraft_account->withdraw( $amount );
        $self->deposit( $amount );
    }
}

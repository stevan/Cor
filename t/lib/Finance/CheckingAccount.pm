
class Finance::CheckingAccount isa Finance::BankAccount {

    has $!overdraft_account : ro;

    method BUILDARGS : strict( overdraft_account => $!overdraft_account );

    method withdraw ($self, $amount) {

        my $overdraft_amount = $amount - $self->balance;

        if ( $!overdraft_account && $overdraft_amount > 0 ) {
            $self->withdraw_from_overdraft( $overdraft_amount );
        }

        $self->next::method( $amount );
    }

    method withdraw_from_overdraft : private ($self, $amount) {
        $!overdraft_account->withdraw( $amount );
        $self->deposit( $amount );
    }
}

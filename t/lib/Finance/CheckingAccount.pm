
class Finance::CheckingAccount isa Finance::BankAccount {

    has $!overdraft_account : ro;

    method BUILDARGS : strict( overdraft_account => $!overdraft_account );

    method withdraw ($self, $amount) {

        my $overdraft_amount = $amount - $self->balance;

        if ( $!overdraft_account && $overdraft_amount > 0 ) {
            $!overdraft_account->withdraw( $overdraft_amount );
            $self->deposit( $overdraft_amount );
        }

        $self->next::method( $amount );
    }
}

package Cor::Compiler::Unit::Role;
# ABSTRACT: compilation unit for roles

use v5.24;
use warnings;
use experimental qw[ signatures postderef ];

use parent 'UNIVERSAL::Object';
use roles  'Cor::Compiler::Unit';

use slots (
    # ...
    _UNITCHECK => sub { [] }
);

sub dependencies ($self) {
    return $self->{ast}->roles->@*
}

sub preamble ($self) {
    return (
        'use v5.24;',
        'use warnings;',
        'use experimental qw[ signatures ];',
        'use decorators qw[ :accessors :constructor ];',
        'use MOP;',
    )
}

sub generate_source ($self) {

    my $meta = $self->{ast};

    # apply the traits

    # NOTE:
    # this needs to happen before we do anything
    # else, because this may result in a modification
    # of the AST object, which then affects the
    # generated source.
    # - SL

    foreach my $slot ( $meta->slots->@* ) {
        if ( $slot->has_attributes ) {
            my @attributes;
            foreach my $attribute ( $slot->attributes->@* ) {
                if ( not $self->_apply_trait( $meta, $slot, $attribute ) ) {
                    push @attributes => $attribute;
                }
            }
            $slot->set_attributes( \@attributes );
        }
    }

    foreach my $method ( $meta->methods->@* ) {
        if ( $method->has_attributes ) {
            my @attributes;
            foreach my $attribute ( $method->attributes->@* ) {
                if ( not $self->_apply_trait( $meta, $method, $attribute ) ) {
                    push @attributes => $attribute;
                }
            }
            $method->set_attributes( \@attributes );
        }
    }

    # ... generate source

    my @src;

    push @src => 'package '
                . $meta->name
                . ($meta->has_version ? ' ' . ($meta->version =~ s/^v//r) : '')
                . ' {';

    push @src => $self->preamble;

    if ( $meta->has_roles ) {
        push @src => $self->generate_roles;
    }

    if ( $meta->has_slots ) {
        push @src => $self->generate_slots;
    }

    if ( $meta->has_methods ) {
        push @src => $self->generate_methods;
    }

    if ( $meta->has_roles ) {
        push @src => '# finalize';
        push @src => 'BEGIN {';
        push @src => 'MOP::Util::compose_roles(MOP::Util::get_meta(__PACKAGE__));';
        push @src => '}';
    }

    push @src => '1;';
    push @src => '}';

    return join "\n" => @src;
}

sub generate_roles ($self) {
    my $meta = $self->{ast};

    my @src;
    push @src => '# roles';
    push @src => 'our @DOES; BEGIN { @DOES = qw['
        .(join ' ' => map $_->name, $meta->roles->@*)
    .'] }';
    return @src;
}

sub generate_slots ($self) {
    my $meta = $self->{ast};

    my @src;
    push @src => '# slots';
    push @src => 'our %HAS; BEGIN { %HAS = (';
    push @src => map {
    '    q[' . $_->name . '] => sub { ' . ($_->has_default ? $_->default : '') . ' },'
    } $meta->slots->@*;
    push @src => ') }';
    return @src;
}

sub generate_methods ($self) {
    my $meta = $self->{ast};

    my (@methods, @private_methods);
    foreach my $method ( $meta->methods->@* ) {
        if ( $method->has_attributes && $method->has_attribute('private') ) {
            push @private_methods => $method;
        }
        else {
            push @methods => $method;
        }
    }

    my %private_method_index = map { $_->name => undef } @private_methods;

    #use Data::Dumper;
    #warn Dumper \%private_method_index;

    my @src;

    if ( @private_methods ) {
        push @src => '# private methods';

        foreach my $method ( @private_methods ) {
            push @src =>
                'my $___' . $method->name . ' = sub '
                . ($method->has_signature  ? ' ' . $method->signature  : '')
                . $self->_compile_method_body( $method->body, \%private_method_index )
                . ';';
        }
    }

    if ( @methods ) {
        push @src => '# methods';

        foreach my $method ( @methods ) {
            push @src =>
                'sub '
                . $method->name
                . ($method->has_attributes
                    ? ' ' . (
                        join ' ' => map {
                            ':'.$_->name.'('.$_->args.')'
                        } $method->attributes->@*
                    )
                    : '')
                . ($method->has_signature  ? ' ' . $method->signature  : '')
                . ($method->is_abstract
                    ? ';'
                    : ' ' . $self->_compile_method_body( $method->body, \%private_method_index ));
        }
    }

    return @src;
}

# ...

sub _apply_trait ( $self, $meta, $topic, $attribute ) {
    if ( my $trait = $self->{traits}->{ $attribute->name } ) {
        $trait->( $meta, $topic, $attribute );
    }
}

sub _compile_method_body ($self, $body, $private_method_index) {

    my $source = $body->source;
    my $offset = 0;

    if ( my @slot_matches = $body->slot_locations->@* ) {

        foreach my $m ( @slot_matches ) {
            my $patch = '$_[0]->{q[' . $m->{match} . ']}';

            #use Data::Dumper;
            #warn Dumper [ $m, [
            #    $source,
            #    length( $source ),
            #    $m->{start} + $offset,
            #    length( $m->{match} )
            #    ] ];

            substr(
                $source,
                $m->{start} + $offset,
                length( $m->{match} ),
            ) = $patch;
            $offset += length( $patch ) - length( $m->{match} );
        }

    }

    if ( my @self_call_matches = $body->self_call_locations->@* ) {

        foreach my $m ( @self_call_matches ) {

            # only compile private methods ...
            next unless exists $private_method_index->{ $m->{match} };

            my $patch = '$___' . $m->{match};

            #use Data::Dumper;
            #warn Dumper [ $m, [
            #    $source,
            #    length( $source ),
            #    $m->{start} + $offset,
            #    length( $m->{match} )
            #    ] ];

            substr(
                $source,
                $m->{start} + $offset,
                length( $m->{match} ),
            ) = $patch;
            $offset += length( $patch ) - length( $m->{match} );
        }

    }

    return $source;

}

1;

__END__

=pod

=cut

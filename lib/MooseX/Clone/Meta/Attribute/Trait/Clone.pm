#!/usr/bin/perl

package MooseX::Clone::Meta::Attribute::Trait::Clone;
use Moose::Role;

with qw(MooseX::Clone::Meta::Attribute::Trait::Clone::Base);

use Carp qw(croak);

sub Moose::Meta::Attribute::Custom::Trait::Clone::register_implementation { __PACKAGE__ }

has clone_refs => (
	isa => "Bool",
	is  => "rw",
	default => 0,
);

has clone_visitor => (
    isa => "Data::Visitor",
    is  => "rw",
    lazy_build => 1,
);

sub _build_clone_visitor {
    my $self = shift;

    require Data::Visitor::Callback;

    Data::Visitor::Callback->new(
        object => sub { $self->clone_object_value($_[1]) },
        tied_as_objects => 1,
    );
}

sub clone_value {
	my ( $self, $target, $proto, %args ) = @_;

	my $clone = $self->clone_value_data( $self->get_value($proto), %args );

	$self->set_value( $target, $clone );
}

sub clone_value_data {
    my ( $self, $value, @args ) = @_;

    if ( blessed($value) ) {
		$self->clone_object_value($value, @args);
    } else {
		if ( $self->clone_refs ) {
			$self->clone_ref_value($value, @args);
		} else {
			my %args = @args;
			return exists $args{init_arg}
				? $args{init_arg} # taken as a literal value
				: $value;
		}
    }
}

sub clone_object_value {
	my ( $self, $value, %args ) = @_;

	if ( $value->can("clone") ) {
		my @clone_args;

		if ( exists $args{init_arg} ) {
			my $init_arg = $args{init_arg};

			if ( ref $init_arg ) {
				if ( ref $init_arg eq 'HASH' )  { @clone_args = %$init_arg }
				elsif ( ref $init_arg eq 'ARRAY' ) { @clone_args = @$init_arg }
				else {
					croak "Arguments to a sub clone should be given in a hash or array reference";
				}
			} else {
				croak "Arguments to a sub clone should be given in a hash or array reference";
			}
		}

		return $value->clone(@clone_args);
	} else {
		croak "Cannot recursively clone a retarded object in " . $args{attr}->name . ". Try something better.";
	}
}

sub clone_ref_value {
    my ( $self, $ref, @args ) = @_;
    $self->clone_visitor->visit($ref);
}

__PACKAGE__

__END__

=pod

=encoding utf8

=head1 NAME

MooseX::Clone::Meta::Attribute::Trait::Clone - The L<Moose::Meta::Attribute>
trait for deeply cloning attributes.

=head1 SYNOPSIS

	# see MooseX::Clone

	has foo => (
		traits => [qw(Clone)],
		isa => "Something",
	);

	$object->clone; # will recursively call $object->foo->clone and set the value properly

=head1 DESCRIPTION

This meta attribute trait provides a C<clone_value> method, in the spirit of
C<get_value> and C<set_value>. This allows clone methods such as the one in
L<MooseX::Clone> to make use of this per-attribute cloning behavior.

=head1 DERIVATION

Deriving this role for your own cloning purposes is encouraged.

This will allow your fine grained cloning semantics to interact with
L<MooseX::Clone> in the Right™ way.

=head1 METHODS

=over 4

=item clone_value $target, $proto, %args

Clones the value the attribute encapsulates from C<$proto> into C<$target>.

=item clone_value_data $value, %args

Does the actual cloning of the value data by delegating to a C<clone> method on
the object if any.

If the object does not support a C<clone> method an error is thrown.

If the value is not an object then it will not be cloned.

In the future support for deep cloning of simple refs will be added too.

=item clone_object_value $object, %args

This is the actual workhorse of C<clone_value_data>.

=back

=cut

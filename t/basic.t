#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';

use Scalar::Util qw(refaddr);

{
    package Bar;
    use Moose;

    with qw(MooseX::Clone);

    has foo => (
        traits => [qw(Clone)],
        isa => "Foo",
        is  => "rw",
        default => sub { Foo->new },
    );

    has same => (
        isa => "Foo",
        is  => "rw",
        default => sub { Foo->new },
    );

    has floo => (
        traits => [qw(NoClone)],
        isa => "Int",
        is  => "rw",
    );

    package Foo;
    use Moose;

    has copy_number => (
        isa => "Int",
        is  => "ro",
        default => 0,
    );

    has some_attr => ( is => "rw", default => "def" );

    sub clone {
        my ( $self, %params ) = @_;

        $self->meta->clone_object( $self, %params, copy_number => $self->copy_number + 1 );
    }
}


my $bar = Bar->new( floo => 3 );

isa_ok( $bar, "Bar" );
isa_ok( $bar->foo, "Foo" );
isa_ok( $bar->same, "Foo" );

is( $bar->floo, 3, "explicit init_arg" );

is( $bar->foo->copy_number, 0, "first copy" );
is( $bar->same->copy_number, 0, "first copy" );

is( $bar->foo->some_attr, 'def', "default value for other attr" );

my $copy = $bar->clone;

isnt( refaddr($bar), refaddr($copy), "copy" );

is( $copy->floo, undef, "NoClone" );

is( $copy->foo->copy_number, 1, "copy number incremented" );
is( $copy->same->copy_number, 0, "not incremented for uncloned attr" );

is( $copy->foo->some_attr, 'def', "default value for other attr" );

isnt( refaddr($bar->foo), refaddr($copy->foo), "copy" );
is( refaddr($bar->same), refaddr($copy->same), "copy" );

is( $copy->clone( foo => { some_attr => "laaa" } )->foo->some_attr, "laaa", "Value carried over to recursive call to clone" );


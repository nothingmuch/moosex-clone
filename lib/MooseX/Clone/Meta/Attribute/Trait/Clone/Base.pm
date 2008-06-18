#!/usr/bin/perl

package MooseX::Clone::Meta::Attribute::Trait::Clone::Base;
use Moose::Role;

use namespace::clean -except => [qw(meta)];

requires "clone_value";

__PACKAGE__

__END__

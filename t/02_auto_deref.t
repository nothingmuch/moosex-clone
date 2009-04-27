##
## These tests make sure MooesX::Clone is aware of
## auto_deref attributes - Evan Carroll me <@> evancarroll.com
## 
package Foo;
use Moose;
with 'MooseX::Clone';

has 'arr_ref' => (
	isa  => 'ArrayRef'
	, is => 'ro'
	, default => sub { [qw/foo bar baz/] }
	, traits  => [qw/Clone/]
);

package Bar;
use Moose;
with 'MooseX::Clone';

has 'arr_ref' => (
	isa => 'ArrayRef'
	, is => 'ro'
	, auto_deref => 1
	, default => sub { [qw/foo bar baz/] }
	, traits  => [qw/Clone/]
);

package Baz;
use Moose;
with 'MooseX::Clone';

has 'arr_ref' => (
	isa => 'ArrayRef'
	, is => 'ro'
	, auto_deref => 1
	, default => sub { [qw/foo bar/] }
	, traits  => [qw/Clone/]
);


package main;
use Test::More tests => 3;
eval { Foo->new->clone };
ok ( !$@, 'cloning simple obj with a ArrayRef' );
eval { Bar->new->clone };
ok ( !$@, 'cloning simple obj with a ArrayRef (3 elements) and auto_deref' );
eval { Bar->new->clone };
ok ( !$@, 'cloning simple obj with a ArrayRef (2 elements) and auto_deref' );

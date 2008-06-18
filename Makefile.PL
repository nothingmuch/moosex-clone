#!/usr/bin/perl -w

use strict;

use ExtUtils::MakeMaker;

WriteMakefile(
	NAME         => 'MooseX::Clone',
	VERSION_FROM => 'lib/MooseX/Clone.pm',
	INSTALLDIRS  => 'site',
	SIGN         => 1,
	PL_FILES     => { },
	PREREQ_PM    => {
		'Test::use::ok' => 0,
        'Hash::Util::FieldHash::Compat' => 0,
        'Moose' => "0.40",
        'Data::Visitor' => '0.15',
        'namespace::clean' => '0.08',
	},
);


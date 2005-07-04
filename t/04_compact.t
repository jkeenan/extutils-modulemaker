# t/04_compact.t

use Test::More qw/no_plan/;
use strict;
use warnings;

BEGIN { use_ok( 'ExtUtils::ModuleMaker' ); }
ok (chdir 'blib/testing' || chdir '../blib/testing', "chdir 'blib/testing'");

#######################################################################

my $MOD;

ok ($MOD  = ExtUtils::ModuleMaker->new
			( {
				NAME		=> 'Sample::Module::Foo',
				COMPACT		=> 1,
				LICENSE		=> 'looselips',
			} ),
	"call ExtUtils::ModuleMaker->new for Sample-Module-Foo");
	
ok ($MOD->complete_build (),
	"call $MOD->complete_build");

########################################################################

ok (chdir 'Sample-Module-Foo',
	"cd Sample-Module-Foo");

#        MANIFEST.SKIP .cvsignore
for (qw/Changes MANIFEST Makefile.PL LICENSE
		README lib t/) {
    ok (-e,
		"$_ exists");
}

########################################################################

ok (open (FILE, 'LICENSE'),
	"reading 'LICENSE'");
my $filetext = do {local $/; <FILE>};
close FILE;

ok ($filetext =~ m/Loose lips sink ships/,
	"correct LICENSE generated");

########################################################################


# t/04_compact.t

use Test::More tests => 15;
use strict;
use warnings;

BEGIN { use_ok( 'ExtUtils::ModuleMaker' ); }
BEGIN { use_ok( 'File::Temp', qw| tempdir |); }

my $tdir = tempdir( CLEANUP => 1);
ok(chdir $tdir, 'changed to temp directory for testing');

#######################################################################

my $mod;

ok($mod  = ExtUtils::ModuleMaker->new
			( {
				NAME		=> 'Sample::Module::Foo',
				COMPACT		=> 1,
				LICENSE		=> 'looselips',
			} ),
	"call ExtUtils::ModuleMaker->new for Sample-Module-Foo");
	
ok( $mod->complete_build(), 'call complete_build()' );

########################################################################

ok(chdir 'Sample-Module-Foo',
	"cd Sample-Module-Foo");

for (qw/Changes MANIFEST Makefile.PL LICENSE
		README lib t/) {
    ok (-e,
		"$_ exists");
}

########################################################################

ok(open (FILE, 'LICENSE'),
	"reading 'LICENSE'");
my $filetext = do {local $/; <FILE>};
close FILE;

ok($filetext =~ m/Loose lips sink ships/,
	"correct LICENSE generated");

########################################################################


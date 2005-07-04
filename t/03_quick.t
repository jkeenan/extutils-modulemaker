# t/03_quick.t

use Test::More tests => 15;
use strict;
use warnings;

BEGIN { use_ok( 'ExtUtils::ModuleMaker' ); }
BEGIN { use_ok( 'File::Temp', qw| tempdir |); }

my $tdir = tempdir( CLEANUP => 1);
ok(chdir $tdir, 'changed to temp directory for testing');

###########################################################################

my $mod;

ok($mod  = ExtUtils::ModuleMaker->new ( {
                NAME        => 'Sample::Module',
            } ),
    "call ExtUtils::ModuleMaker->new for Sample-Module");
    
ok( $mod->complete_build(), 'call complete_build()' );

########################################################################

ok(chdir 'Sample/Module',
    "cd Sample/Module");

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

ok($filetext =~ m/Terms of Perl itself/,
    "correct LICENSE generated");

########################################################################


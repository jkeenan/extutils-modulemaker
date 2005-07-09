# t/08_modulemaker.t
use strict;
local $^W = 1;
use Test::More 
# tests => 8;
qw(no_plan);

BEGIN { use_ok('ExtUtils::ModuleMaker'); }
BEGIN { use_ok( 'Cwd' ); }
use lib ("./t/testlib");
use _Auxiliary qw(
    rmtree
);

my $cwd = cwd();

# Manually create 'tmp' directory for testing and move into it

my $tmp = 'tmp';

ok((mkdir $tmp, 0755), "able to create testing directory");
ok(chdir $tmp, 'changed to tmp directory for testing');

# Simple test of modulemaker utility in non-interactive mode

ok(! system("$^X -Mblib $cwd/blib/script/modulemaker -Icn XYZ::ABC"), 
    "able to call modulemaker utility");

ok(-d 'XYZ-ABC', "compact top directory created");
ok(-f "XYZ-ABC/$_", "$_ file created")
    for qw| Changes LICENSE MANIFEST Makefile.PL README Todo |;
ok(-d "XYZ-ABC/$_", "$_ directory created")
    for qw| lib t |;

# Cleanup 'tmp' directory following testing

ok(chdir $cwd, 'changed back to original directory after testing');
rmtree($tmp);
ok(! -d $tmp, "tmp directory has been removed");


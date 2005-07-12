# t/09_mmkr.t
use strict;
local $^W = 1;
use Test::More 
# tests => 8;
qw(no_plan);

BEGIN { use_ok('ExtUtils::ModuleMaker'); }
BEGIN { use_ok('File::Temp', qw| tempdir |); }
BEGIN { use_ok('Cwd'); }
use lib ("./t/testlib");
use _Auxiliary qw(
    check_MakefilePL 
);

# Simple tests of modulemaker utility in non-interactive mode

my ($tdir, $topdir);
my $cwd = cwd();

{
    # provide name and call for compact top-level directory

    $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    ok(! 
      system("$^X -I$cwd/blib/lib $cwd/blib/script/modulemaker -Icn XYZ::ABC"), 
        "able to call modulemaker utility");

    $topdir = "XYZ-ABC"; 
    ok(-d $topdir, "compact top directory created");
    ok(-f "$topdir/$_", "$_ file created")
        for qw| Changes LICENSE MANIFEST Makefile.PL README Todo |;
    ok(-d "$topdir/$_", "$_ directory created")
        for qw| lib t |;
    
#    my @pred = (
#        "XYZ::ABC",
#        "lib\/XYZ\/ABC\.pm",
#        "A\.\\sU\.\\sThor",
#        "a\.u\.thor\@a\.galaxy\.far\.far\.away",
#        "Module\\sabstract\\s\\(<=\\s44\\scharacters\\)\\sgoes\\shere",
#    );
#    ok( (check_MakefilePL($topdir, \@pred)), 
#        "Makefile.PL has predicted values");

}

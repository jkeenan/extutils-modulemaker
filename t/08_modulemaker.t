# t/08_modulemaker.t
use strict;
local $^W = 1;
use Test::More 
# tests => 8;
qw(no_plan);

BEGIN { use_ok('ExtUtils::ModuleMaker'); }
use lib ("./t/testlib");
use _Auxiliary qw(
    setuptmpdir
    cleanuptmpdir
);

my ($cwd, $tmp);

{
    # Simple test of modulemaker utility in non-interactive mode
    # provide name and call for compact top-level directory
    ($cwd, $tmp) = setuptmpdir();  # generates 2 oks
    
    ok(! system("$^X -Mblib $cwd/blib/script/modulemaker -Icn XYZ::ABC"), 
        "able to call modulemaker utility");
    
    ok(-d 'XYZ-ABC', "compact top directory created");
    ok(-f "XYZ-ABC/$_", "$_ file created")
        for qw| Changes LICENSE MANIFEST Makefile.PL README Todo |;
    ok(-d "XYZ-ABC/$_", "$_ directory created")
        for qw| lib t |;
    
    cleanuptmpdir($cwd, $tmp);  # generates 2 oks
}

{
    # Simple test of modulemaker utility in non-interactive mode
    # provide name and call for non-compact top-level directory
    ($cwd, $tmp) = setuptmpdir();  # generates 2 oks
    
    ok(! system("$^X -Mblib $cwd/blib/script/modulemaker -In XYZ::ABC"), 
        "able to call modulemaker utility");
    
    ok(-d 'XYZ', "non-compact top directory created");
    ok(-d "XYZ/ABC", "next level directory created");

    ok(-f "XYZ/ABC/$_", "$_ file created")
        for qw| Changes LICENSE MANIFEST Makefile.PL README Todo |;
    ok(-d "XYZ/ABC/$_", "$_ directory created")
        for qw| lib t |;
    
    cleanuptmpdir($cwd, $tmp);  # generates 2 oks
}


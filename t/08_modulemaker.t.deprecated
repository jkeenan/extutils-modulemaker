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
    check_MakefilePL 
);

# Simple tests of modulemaker utility in non-interactive mode

my ($cwd, $tmp, $topdir);

{
    # provide name and call for compact top-level directory
    ($cwd, $tmp) = setuptmpdir();  # generates 2 oks
    
#    ok(! system("$^X -Mblib $cwd/blib/script/modulemaker -Icn XYZ::ABC"), 
#        "able to call modulemaker utility");
#   
#    $topdir = "XYZ-ABC"; 
#    ok(-d $topdir, "compact top directory created");
#    ok(-f "$topdir/$_", "$_ file created")
#        for qw| Changes LICENSE MANIFEST Makefile.PL README Todo |;
#    ok(-d "$topdir/$_", "$_ directory created")
#        for qw| lib t |;
#    
#    my @pred = (
#        "XYZ::ABC",
#        "lib\/XYZ\/ABC\.pm",
#        "A\.\\sU\.\\sThor",
#        "a\.u\.thor\@a\.galaxy\.far\.far\.away",
#        "Module\\sabstract\\s\\(<=\\s44\\scharacters\\)\\sgoes\\shere",
#    );
#    ok( (check_MakefilePL($topdir, \@pred)), 
#        "Makefile.PL has predicted values");

    cleanuptmpdir($cwd, $tmp);  # generates 2 oks
}

#TODO: {
#    local $TODO = 'I dunno';
#    # provide name and call for non-compact top-level directory
#    ($cwd, $tmp) = setuptmpdir();  # generates 2 oks
#    
#    ok(! system("$^X -Mblib $cwd/blib/script/modulemaker -In XYZ::ABC"), 
#        "able to call modulemaker utility");
#    
#    $topdir = "XYZ/ABC"; 
#    ok(-d 'XYZ', "non-compact top directory created");
#    ok(-d $topdir, "next level directory created");
#
#    ok(-f "$topdir/$_", "$_ file created")
#        for qw| Changes LICENSE MANIFEST Makefile.PL README Todo |;
#    ok(-d "$topdir/$_", "$_ directory created")
#        for qw| lib t |;
#    
#    my @pred = (
#        "XYZ::ABC",
#        "lib\/XYZ\/ABC\.pm",
#        "A\.\\sU\.\\sThor",
#        "a\.u\.thor\@a\.galaxy\.far\.far\.away",
#        "Module\\sabstract\\s\\(<=\\s44\\scharacters\\)\\sgoes\\shere",
#    );
#    ok( (check_MakefilePL($topdir, \@pred)), 
#        "Makefile.PL has predicted values");
#
#    cleanuptmpdir($cwd, $tmp);  # generates 2 oks
#}
#
#{
#    # provide name and call for compact top-level directory
#    # and add in author name
#    ($cwd, $tmp) = setuptmpdir();  # generates 2 oks
#    
#    ok(! system("$^X -Mblib $cwd/blib/script/modulemaker  -Icn XYZ::ABC -u \"James E. Keenan\""), 
#        "able to call modulemaker utility");
#   
#    $topdir = "XYZ-ABC"; 
#    ok(-d $topdir, "compact top directory created");
#    ok(-f "$topdir/$_", "$_ file created")
#        for qw| Changes LICENSE MANIFEST Makefile.PL README Todo |;
#    ok(-d "$topdir/$_", "$_ directory created")
#        for qw| lib t |;
#    
#    my @pred = (
#        "XYZ::ABC",
#        "lib\/XYZ\/ABC\.pm",
#        "James\\sE\.\\sKeenan",
#        "a\.u\.thor\@a\.galaxy\.far\.far\.away",
#        "Module\\sabstract\\s\\(<=\\s44\\scharacters\\)\\sgoes\\shere",
#    );
#    ok( (check_MakefilePL($topdir, \@pred)), 
#        "Makefile.PL has predicted values");
#
#    cleanuptmpdir($cwd, $tmp);  # generates 2 oks
#}

__END__

# Not yet working

{
    # provide name and call for compact top-level directory
    # and add in author name
    # and add in author email
    ($cwd, $tmp) = setuptmpdir();  # generates 2 oks
    
    ok(! system("$^X -Mblib $cwd/blib/script/modulemaker  -Icn XYZ::ABC -u \"James E. Keenan\" -e \"jkeen\@v\" "), 
        "able to call modulemaker utility");
   
    $topdir = "XYZ-ABC"; 
    ok(-d $topdir, "compact top directory created");
    ok(-f "$topdir/$_", "$_ file created")
        for qw| Changes LICENSE MANIFEST Makefile.PL README Todo |;
    ok(-d "$topdir/$_", "$_ directory created")
        for qw| lib t |;
    
    my @pred = (
        "XYZ::ABC",
        "lib\/XYZ\/ABC\.pm",
        "James\\sE\.\\sKeenan",
#        "a\.u\.thor\@a\.galaxy\.far\.far\.away",
        "jkeen\@v",
        "Module\\sabstract\\s\\(<=\\s44\\scharacters\\)\\sgoes\\shere",
    );
    ok( (check_MakefilePL($topdir, \@pred)), 
        "Makefile.PL has predicted values");

    cleanuptmpdir($cwd, $tmp);  # generates 2 oks
}


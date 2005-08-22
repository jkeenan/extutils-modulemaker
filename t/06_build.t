# t/06_build.t
BEGIN {
    use Test::More 
    tests => 20;
#    qw(no_plan);
    $realhome = $ENV{HOME};
    local $ENV{HOME} = "./t/testlib/pseudohome";
    ok(-d $ENV{HOME}, "pseudohome directory exists");
    like($ENV{HOME}, qr/pseudohome/, "pseudohome identified");
    use_ok( 'File::Copy' );
    $personal_dir = "$ENV{HOME}/.modulemaker"; 
    $personal_defaults_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
    if (-f "$personal_dir/$personal_defaults_file") {
        move("$personal_dir/$personal_defaults_file", 
             "$personal_dir/$personal_defaults_file.bak"); 
        ok(-f "$personal_dir/$personal_defaults_file.bak",
            "personal defaults stored as .bak"); 
    } else {
        ok(1, "no personal defaults file found");
    }
    use_ok( 'ExtUtils::ModuleMaker' );
    use_ok( 'Cwd');
}
END {
    $ENV{HOME} = $realhome;
    if (-f "$personal_dir/$personal_defaults_file.bak") {
        move("$personal_dir/$personal_defaults_file.bak", 
             "$personal_dir/$personal_defaults_file"); 
        ok(-f "$personal_dir/$personal_defaults_file",
            "personal defaults restored"); 
    } else {
        ok(1, "no personal defaults file found");
    }
}
use strict;
local $^W = 1;

my $odir = cwd();

SKIP: {
    eval { require 5.006_001 and require Module::Build };
    skip "tests require File::Temp, core with 5.6, and require Module::Build", 
        16 if $@;
    use warnings;
    use_ok( 'File::Temp', qw| tempdir |);
    use lib ("./t/testlib");
    use _Auxiliary qw(
        read_file_string
        six_file_tests
    );
    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    ########################################################################

    my $mod;
    my $testmod = 'Gamma';

    ok( 
        $mod = ExtUtils::ModuleMaker->new( 
            NAME           => "Alpha::$testmod",
            ABSTRACT       => 'Test of the capacities of EU::MM',
            COMPACT        => 1,
            CHANGES_IN_POD => 1,
            BUILD_SYSTEM   => 'Module::Build',
            AUTHOR         => 'Phineas T. Bluster',
            CPANID         => 'PTBLUSTER',
            ORGANIZATION   => 'Peanut Gallery',
            WEBSITE        => 'http://www.anonymous.com/~phineas',
            EMAIL          => 'phineas@anonymous.com',
        ),
        "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
    );

    ok( $mod->complete_build(), 'call complete_build()' );

    ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );

    my ($filetext);
    ok($filetext = read_file_string('Build.PL'),
        'Able to read Build.PL');

    six_file_tests(7, $testmod); # first arg is # entries in MANIFEST

} # end SKIP block

ok(chdir $odir, 'changed back to original directory after testing');


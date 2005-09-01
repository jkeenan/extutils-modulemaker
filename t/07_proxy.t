# t/07_proxy.t
use strict;
local $^W = 1;
use Test::More 
tests =>  58;
# qw(no_plan);
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'Cwd');
use_ok( 'ExtUtils::ModuleMaker::Utility', qw( 
        _preexists_mmkr_directory
        _make_mmkr_directory
        _restore_mmkr_dir_status
    )
);
use lib ("./t/testlib");
use_ok( 'Auxiliary', qw(
        _process_personal_defaults_file 
        _reprocess_personal_defaults_file 
    )
);

my $odir = cwd();

SKIP: {
    eval { require 5.006_001 and require Module::Build };
    skip "tests require File::Temp, core with 5.6, and require Module::Build", 
        (58 - 4) if $@;
    use warnings;
    use_ok( 'File::Temp', qw| tempdir |);
    use lib ("./t/testlib");
    use Auxiliary qw(
        read_file_string
        six_file_tests
    );
    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    ########################################################################

    my $mmkr_dir_ref = _preexists_mmkr_directory();
    my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
    ok( $mmkr_dir, "personal defaults directory now present on system");

    my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
    my $pers_def_ref = 
        _process_personal_defaults_file( $mmkr_dir, $pers_file );

    my ($mod, $filetext);
    my $testmod = 'Delta';

    ########## Variant:  'Module::Build and proxy Makefile.PL' ##########

    ok( 
        $mod = ExtUtils::ModuleMaker->new(
            NAME           => "Alpha::$testmod",
            ABSTRACT       => 'Test of the capacities of EU::MM',
            COMPACT        => 1,
            CHANGES_IN_POD => 1,
            BUILD_SYSTEM   => 'Module::Build and proxy Makefile.PL',
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

    for ( qw/Build.PL LICENSE Makefile.PL MANIFEST README Todo/) {
        ok( -f, "file $_ exists" );
    }
    ok(! -f 'Changes', 'Changes file correctly not created');
    for ( qw/lib scripts t/) {
        ok( -d, "directory $_ exists" );
    }

    ok($filetext = read_file_string('Makefile.PL'),
        'Able to read Makefile.PL');
    ok($filetext =~ m|Module::Build::Compat|,
        'Makefile.PL will call Module::Build or install it');

    ok($filetext = read_file_string('Build.PL'),
        'Able to read Build.PL');

    six_file_tests(8, $testmod); # first arg is # entries in MANIFEST

    ########## Variant:  'Module::Build and Proxy' ##########

    ok( 
        $mod = ExtUtils::ModuleMaker->new(
            NAME           => "Alpha::$testmod",
            ABSTRACT       => 'Test of the capacities of EU::MM',
            COMPACT        => 1,
            CHANGES_IN_POD => 1,
            BUILD_SYSTEM   => 'Module::Build and Proxy',
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

    for ( qw/Build.PL LICENSE Makefile.PL MANIFEST README Todo/) {
        ok( -f, "file $_ exists" );
    }
    ok(! -f 'Changes', 'Changes file correctly not created');
    for ( qw/lib scripts t/) {
        ok( -d, "directory $_ exists" );
    }

    ok($filetext = read_file_string('Makefile.PL'),
        'Able to read Makefile.PL');
    ok($filetext =~ m|Module::Build::Compat|,
        'Makefile.PL will call Module::Build or install it');

    ok($filetext = read_file_string('Build.PL'),
        'Able to read Build.PL');

    six_file_tests(8, $testmod); # first arg is # entries in MANIFEST
 
    _reprocess_personal_defaults_file($pers_def_ref);

    ok(chdir $odir, 'changed back to original directory after testing');

    ok( _restore_mmkr_dir_status($mmkr_dir_ref),
        "original presence/absence of .modulemaker directory restored");

} # end SKIP block


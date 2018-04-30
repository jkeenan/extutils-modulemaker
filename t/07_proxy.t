# t/07_proxy.t
use strict;
use warnings;
use Carp;
use File::Spec;
use File::Temp qw(tempdir);
use Module::Build;
use Test::More tests =>  43;
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
    prepare_mockdirs
    read_file_string
    five_file_tests
) );

{
    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    ########################################################################

    my ($mod, $filetext);
    my $testmod = 'Delta';
    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);

    note("Case 1: Module::Build and proxy Makefile.PL");

    ok( $mod = ExtUtils::ModuleMaker->new(
            NAME           => $module_name,
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
        "call ExtUtils::ModuleMaker->new for $dist_name"
    );

    ok( $mod->complete_build(), 'call complete_build()' );

    for my $f ( qw| MANIFEST Makefile.PL Build.PL LICENSE README | ) {
        my $ff = File::Spec->catfile($dist_name, $f);
        ok (-e $ff, "$ff exists");
    }
    ok(! -f File::Spec->catfile($dist_name, 'Changes'),
        "Changes file not created");
    for my $d ( qw| lib scripts t | ) {
        my $dd = File::Spec->catdir($dist_name, $d);
        ok(-d $dd, "Directory '$dd' exists");
    }

    ok($filetext = read_file_string(File::Spec->catfile($dist_name, 'Makefile.PL')),
        'Able to read Makefile.PL');
    ok($filetext =~ m|Module::Build::Compat|,
        'Makefile.PL will call Module::Build or install it');

    ok($filetext = read_file_string(File::Spec->catfile($dist_name, 'Build.PL')),
        'Able to read Build.PL');

    five_file_tests(8, \@components); # first arg is # entries in MANIFEST

    ########## Variant:  'Module::Build and Proxy' ##########

    note("Case 2: Module::Build and Proxy");

    ok( $mod = ExtUtils::ModuleMaker->new(
            NAME           => $module_name,
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
        "call ExtUtils::ModuleMaker->new for $dist_name"
    );

    ok( $mod->complete_build(), 'call complete_build()' );

    for my $f ( qw| MANIFEST Makefile.PL Build.PL LICENSE README | ) {
        my $ff = File::Spec->catfile($dist_name, $f);
        ok (-e $ff, "$ff exists");
    }
    ok(! -f File::Spec->catfile($dist_name, 'Changes'),
        "Changes file not created");
    for my $d ( qw| lib scripts t | ) {
        my $dd = File::Spec->catdir($dist_name, $d);
        ok(-d $dd, "Directory '$dd' exists");
    }

    ok($filetext = read_file_string(File::Spec->catfile($dist_name, 'Makefile.PL')),
        'Able to read Makefile.PL');
    ok($filetext =~ m|Module::Build::Compat|,
        'Makefile.PL will call Module::Build or install it');

    ok($filetext = read_file_string(File::Spec->catfile($dist_name, 'Build.PL')),
        'Able to read Build.PL');

    five_file_tests(8, \@components); # first arg is # entries in MANIFEST
}

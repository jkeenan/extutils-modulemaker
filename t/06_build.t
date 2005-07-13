# t/06_build.t
use strict;
local $^W = 1;
use Test::More tests => 15;

BEGIN { use_ok('ExtUtils::ModuleMaker'); }
BEGIN { use_ok( 'File::Temp', qw| tempdir |); }
BEGIN { use_ok( 'Cwd' ); }
use lib ("./t/testlib");
use _Auxiliary qw(
    read_file_string
    six_file_tests
);

my $odir = cwd();
my $tdir = tempdir( CLEANUP => 1);
ok(chdir $tdir, 'changed to temp directory for testing');

########################################################################

my $mod;
my $testmod = 'Gamma';

SKIP: {
    eval { require Module::Build };
    skip "Module::Build not installed", 10 if $@;

    ok( 
        $mod = ExtUtils::ModuleMaker->new( 
            NAME           => "Alpha::$testmod",
            ABSTRACT       => 'Test of the capacities of EU::MM',
            COMPACT        => 1,
            CHANGES_IN_POD => 1,
            BUILD_SYSTEM   => 'Module::Build',
            AUTHOR         => {
               'NAME'         => 'Phineas T. Bluster',
               'CPANID'       => 'PTBLUSTER',
               'ORGANIZATION' => 'Peanut Gallery',
               'EMAIL'        => 'phineas@anonymous.com',
               'WEBSITE'      => 'http://www.anonymous.com/~phineas',
            },
        ),
        "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
    );
    
    ok( $mod->complete_build(), 'call complete_build()' );
    
    ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );
    
    my ($filetext);
    ok($filetext = read_file_string('Build.PL'),
        'Able to read Build.PL');
    
    six_file_tests(7, $testmod); # first arg is # entries in MANIFEST
}

ok(chdir $odir, 'changed back to original directory after testing');


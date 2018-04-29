# t/01_ini.t - check module loading
use strict;
use warnings;
use File::Spec;
use File::Path 2.15 qw(make_path);
use Test::More tests =>  7;
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'File::Save::Home', qw|
    get_home_directory
    get_subhome_directory_status
| );
use lib ( qw| ./t/testlib | );
use_ok( 'MockHomeDir' );


my ($realhome, $subdir, $mmkr_dir_ref);

ok( $realhome = get_home_directory(),
    "\$HOME or home-equivalent directory found on system");

$subdir = '.modulemaker';
$mmkr_dir_ref = get_subhome_directory_status($subdir);
(-d $mmkr_dir_ref->{abs})
    ? pass("Directory $mmkr_dir_ref->{abs} found on this system")
    : pass("Directory $mmkr_dir_ref->{abs} not found on this system");

my ($home_dir, $personal_defaults_dir);
$home_dir = MockHomeDir::home_dir();
ok(-d $home_dir, "Directory $home_dir created to mock home directory");
$personal_defaults_dir =
    File::Spec->catdir($home_dir, $subdir, qw| lib ExtUtils Modulemaker Personal | );
ok(make_path($personal_defaults_dir, { mode => 0711 }),
    "Able to create directory $personal_defaults_dir for testing");


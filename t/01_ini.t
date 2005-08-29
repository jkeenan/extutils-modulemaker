# t/01_ini.t - check module loading
use strict;
local $^W = 1;
use Test::More 
tests => 11;
# qw(no_plan);
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::Utility', qw|
    _get_home_directory
    _get_personal_defaults_directory
    _restore_personal_dir_status
| );
use_ok( 'File::Copy' );
use_ok( 'File::Spec' );
use_ok( 'Carp' );

my ($realhome, $personal_dir, $no_personal_dir_flag);

ok( $realhome = _get_home_directory(), 
    "HOME or home-equivalent directory found on system");

($personal_dir, $no_personal_dir_flag)  = _get_personal_defaults_directory();
ok( $personal_dir, "personal defaults directory found on system");

=pod Nonexistent_.modulemaker_Directory
    The previous test created a .modulemaker directory underneath the HOME
directory if it did not previously exist.  Let us temporarily rename that
directory, then test if we can create a personal defaults directory.  We will
perform that test by creating a new EU::MM object.  Since EU::MM::new() calls
_get_personal_defaults_directory() internally, successful creation of a new
EU::MM object will imply successful creation of a .modulemaker directory.
Then, we will then copy back the hidden directory to its proper place.

=cut

my ($vol, $dirs, $file) = File::Spec->splitpath( $personal_dir );
my $tempdir = File::Spec->catfile( $dirs, $file . '_temp' );
ok( move ($personal_dir, $tempdir), 
    "personal defaults directory temporarily renamed");
my $mod = ExtUtils::ModuleMaker->new( NAME => 'Alpha::Beta' );
isa_ok($mod, 'ExtUtils::ModuleMaker');
ok( move ($tempdir, $personal_dir), 
    "personal defaults directory restored");

ok( _restore_personal_dir_status($personal_dir, $no_personal_dir_flag),
    "original presence/absence of .modulemaker directory restored");


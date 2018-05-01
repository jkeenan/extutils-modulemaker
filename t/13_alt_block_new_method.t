# t/13_alt_block_new_method.t
# test whether methods overriding those provided by EU::MM::StandardText
# create files as intended
use strict;
use warnings;
use Carp;
use Cwd;
use File::Copy;
use File::Spec;
use File::Temp qw(tempdir);
use File::Copy::Recursive::Reduced 0.006 qw(fcopy);
use Test::More tests =>  26;
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'Cwd');
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
    prepare_mockdirs
    read_file_string
    compact_build_tests
) );
my $cwd = cwd();

{
    note("Set:   Alt_block_new_method");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $alt = File::Spec->catfile($cwd, 't', 'testlib',
        'ExtUtils', 'ModuleMaker', 'Alt_block_new_method.pm');
    ok(-f $alt, "Located $alt prior to use in testing");
    my $target_lib_dir = File::Spec->catdir($tdir, 'lib');
    my $target_dir = File::Spec->catdir($target_lib_dir,
        'ExtUtils', 'ModuleMaker');
    my $target_file = File::Spec->catfile($target_dir, 'Alt_block_new_method.pm');
    my $rv = fcopy($alt => $target_file)
        or croak "Unable to copy $alt to $target_file for testing";
    ok($rv, "fcopy() returned true value");
    ok(-f $target_file, "$target_file created");

    my $testmod = 'Beta';
    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    my $path_str = File::Spec->catdir(@components);

    unshift @INC, $target_lib_dir;
    my ($mod);
    ok( $mod = ExtUtils::ModuleMaker->new(
            NAME           => $module_name,
            COMPACT        => 1,
            ALT_BUILD      => q{ExtUtils::ModuleMaker::Alt_block_new_method},
        ),
        "call ExtUtils::ModuleMaker->new for $dist_name"
    );

    ok( $mod->complete_build(), 'call complete_build()' );

    my ($module_file, $test_file) = compact_build_tests(\@components);

    my $filetext = read_file_string($module_file);
    my $newstr = <<'ENDNEW';
sub new {
    my $class = shift;
    my $self = bless ({}, $class);
    return $self;
}
ENDNEW

    ok( (index($filetext, $newstr)) > -1,
        "string present in file as predicted");

    ok(chdir $cwd, "Able to change back to starting directory");
}


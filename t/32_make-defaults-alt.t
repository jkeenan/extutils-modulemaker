# t/32_make-defaults-alt.t
# tests of options to make modulemaker selections default personal values
# where the directory tree needed to store Personal::Defaults does not fully
# exist
use strict;
use warnings;
use Carp;
use Cwd;
use File::Spec;
use File::Path 2.15 qw(remove_tree);
use File::Temp qw(tempdir);
use Test::More tests => 48;
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
    prepare_mockdirs
    prepare_mock_homedir
    compact_build_tests
    read_file_string
    check_MakefilePL
) );

=pod

Objective in this file is to exercise the part of
C<EU::MM::make_selections_defaults()> starting at:

    if (! -d $full_dir) {

Here, C<$full_dir()> would be
F</E<lt>mockhomeE<gt>/.modulemaker/ExtUtils/ModuleMaker/Personal/>.  The
approach to testing used in this version of EUMM, centered in
C<prepare_mockdirs()> auto-creates this directory.  Hence, we have to remove
part of this directory if we're to exercise this section of
C<make_selection_defaults()>.

=cut

my $cwd = cwd();

my ($home_dir) = prepare_mock_homedir();
local $ENV{HOME} = $home_dir;

my $mmkr_dir = File::Spec->catdir($home_dir, '.modulemaker');
for my $d ($home_dir, $mmkr_dir) {
    ok(-d $d, "$d has been created");
}

opendir my $DIRH, $mmkr_dir or croak "Unable to open dirhandle";
my @entries = grep { ! m/^\.{1,2}$/ } readdir $DIRH;
closedir $DIRH or croak "Unable to close dirhandle";
cmp_ok(@entries, '==', 1, "$mmkr_dir starts out with one entry");

my $topdir = File::Spec->catdir($mmkr_dir, $entries[0]);
ok(-d $topdir, "$topdir is underneath $mmkr_dir");

my $removed_count = remove_tree($topdir, {
    error  => \my $err_list, safe => 1, });
is($removed_count, 3, "Removed 'ExtUtils/ModuleMaker/Personal'");
ok(! -d $topdir, "$topdir has been deleted");
ok(-d $mmkr_dir, "$mmkr_dir still exists");

{
    my ($module_name, @components, $dist_name, $path_str);
    my ($module_file, $test_file);
    my ($mkfl, $bigstr);

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    @components = qw( Alpha Beta Gamma );
    $module_name = join('::' => @components);
    $dist_name = join('-' => @components);
    $path_str = File::Spec->catdir(@components);

    my $abstract = "Test make_selections_defaults()";
    my $author = 'Chango Ta Beni';
    my $email  = 'chango_ta_beni@example.com';

    my $obj1 = ExtUtils::ModuleMaker->new(
        NAME                => $module_name,
        ABSTRACT            => $abstract,
        COMPACT             => 1,
        AUTHOR              => $author,
        EMAIL               => $email,
        SAVE_AS_DEFAULTS    => 1,
    );
    isa_ok( $obj1, 'ExtUtils::ModuleMaker' );

    ok( $obj1->complete_build(), 'call complete_build()' );

    ($module_file, $test_file) = compact_build_tests(\@components);

    $mkfl = File::Spec->catfile( $dist_name, q{Makefile.PL} );
    ok(-f $mkfl, "Located Makefile.PL");
    $bigstr = read_file_string($mkfl);
    like($bigstr, qr/NAME\s+=>\s+'$module_name/s,
        "Got NAME as expected");
    like($bigstr, qr/ABSTRACT\s+=>\s+'$abstract/s,
        "Got ABSTRACT as expected");
    like($bigstr, qr/AUTHOR\s+=>\s+'$author\s+\($email\)'/s,
        "Got AUTHOR and EMAIL as expected");

    # Create a new instance which we expect will have::
    # (a) a compact top-level directory,
    # (b) author and email as in first instance, automatically populated,
    # (c) EUMM default abstract.

    my $obj2 = ExtUtils::ModuleMaker->new(
        NAME    => q{Ackus::Frackus},
    );
    isa_ok( $obj2, 'ExtUtils::ModuleMaker' );

    ok( $obj2->complete_build(), 'call complete_build()' );

    $module_name = $obj2->{NAME};
    @components = split(/::/, $module_name);
    $dist_name = join('-' => @components);
    $path_str = File::Spec->catdir(@components);
    $module_file = File::Spec->catfile(
        'lib', @components[0 .. ($#components - 1)], "$components[-1].pm");

    ($module_file, $test_file) = compact_build_tests(\@components);

    $mkfl = File::Spec->catfile( $dist_name, q{Makefile.PL} );
    ok(-f $mkfl, "Located Makefile.PL");
    $bigstr = read_file_string($mkfl);
    like($bigstr, qr/NAME\s+=>\s+'$module_name/s,
        "Got NAME as expected");
    unlike($bigstr, qr/ABSTRACT\s+=>\s+'$abstract/s,
        "Got ABSTRACT different from first object");
    like($bigstr, qr/AUTHOR\s+=>\s+'$author\s+\($email\)'/s,
        "Got AUTHOR and EMAIL as expected");

    ok(chdir $cwd, 'back to where we stared');
}


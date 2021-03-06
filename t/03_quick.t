# t/03_quick.t
use strict;
use warnings;
use Test::More tests => 58;
use Carp;
use Cwd;
use File::Spec;
use File::Temp qw(tempdir);
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
    prepare_mockdirs
    basic_file_and_directory_tests
    license_text_test
) );
use_ok( 'ExtUtils::ModuleMaker::MockHomeDir' );

my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
local $ENV{HOME} = $home_dir;

note("Case 1: No personal defaults file");

{
    my $cwd = cwd();

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    ###########################################################################

    my $mod;

    my @components = qw| Sample Module |;
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    my $path_str = File::Spec->catdir(@components);
    ok($mod  = ExtUtils::ModuleMaker->new ( NAME => $module_name),
        "call ExtUtils::ModuleMaker->new for $dist_name");

    ok( $mod->complete_build(), 'call complete_build()' );

    basic_file_and_directory_tests($path_str);
    license_text_test($path_str, qr/Terms of Perl itself/);

    ########################################################################

    # tests of inheritability of constructor
    # note:  attributes must not be thought of as inherited because
    # constructor freshly repopulates data structure with default values

    my ($modparent, $modchild, $modgrandchild);

    ok($modparent  = ExtUtils::ModuleMaker->new(
        NAME => 'Sample::Module',
        ABSTRACT => 'The quick brown fox',
        debug => 0,
    ), "call ExtUtils::ModuleMaker->new for Sample-Module");
    isa_ok($modparent, "ExtUtils::ModuleMaker", "object is an EU::MM object");
    is($modparent->{NAME}, 'Sample::Module', "NAME '$modparent->{NAME}' is correct");
    is($modparent->{ABSTRACT}, 'The quick brown fox', "ABSTRACT '$modparent->{ABSTRACT}' is correct");
    is($modparent->{AUTHOR}, 'A. U. Thor', "AUTHOR '$modparent->{AUTHOR}' is correct");

    $modchild = $modparent->new(
        'NAME'     => 'Alpha::Beta',
        ABSTRACT => 'The quick brown fox',
        debug => 0,
    );
    isa_ok($modchild, "ExtUtils::ModuleMaker", "constructor is inheritable");
    is($modchild->{NAME}, 'Alpha::Beta', "child NAME '$modchild->{NAME}' is correct");
    is($modchild->{ABSTRACT}, 'The quick brown fox', "child ABSTRACT '$modchild->{ABSTRACT}' is correct");
    is($modchild->{AUTHOR}, 'A. U. Thor', "child AUTHOR '$modchild->{AUTHOR}' is correct");

    ok($modgrandchild  = $modchild->new(
        NAME => 'Gamma::Delta',
        ABSTRACT => 'The quick brown vixen',
        debug => 0,
    ), "call ExtUtils::ModuleMaker->new for Sample-Module");
    isa_ok($modgrandchild, "ExtUtils::ModuleMaker", "object is an EU::MM object");
    is($modgrandchild->{NAME}, 'Gamma::Delta', "grandchild NAME '$modgrandchild->{NAME}' is correct");
    is($modgrandchild->{ABSTRACT}, 'The quick brown vixen', "grandchild's explicitly coded ABSTRACT is correct");
    is($modgrandchild->{AUTHOR}, 'A. U. Thor', "grandchild AUTHOR '$modgrandchild->{AUTHOR}' is correct");

    ok(chdir $cwd, "Changed back to original directory");
}

note("Case 2: Personal defaults file present");

my $personal_defaults_file = ExtUtils::ModuleMaker::MockHomeDir::personal_defaults_file();
ok(-f $personal_defaults_file, "Able to create file $personal_defaults_file for testing");

{
    my $cwd = cwd();

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    ###########################################################################

    my $mod;

    my @components = qw| Sample Module |;
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    my $path_str = File::Spec->catdir(@components);
    ok($mod  = ExtUtils::ModuleMaker->new ( NAME => $module_name),
        "call ExtUtils::ModuleMaker->new for $dist_name");

    ok( $mod->complete_build(), 'call complete_build()' );

    basic_file_and_directory_tests($path_str);
    license_text_test($path_str, qr/Terms of Perl itself/);

    ########################################################################

    # tests of inheritability of constructor
    # note:  attributes must not be thought of as inherited because
    # constructor freshly repopulates data structure with default values

    my ($modparent, $modchild, $modgrandchild);

    ok($modparent  = ExtUtils::ModuleMaker->new(
        NAME => 'Sample::Module',
        debug => 0,
    ), "call ExtUtils::ModuleMaker->new for Sample-Module");
    isa_ok($modparent, "ExtUtils::ModuleMaker", "object is an EU::MM object");
    is($modparent->{NAME}, 'Sample::Module', "NAME '$modparent->{NAME}' is correct");
    is($modparent->{ABSTRACT}, q{Module abstract (<= 44 characters) goes here}, "ABSTRACT '$modparent->{ABSTRACT}' is correct");
    is($modparent->{AUTHOR}, q{Hilton Stallone}, "AUTHOR '$modparent->{AUTHOR}' is correct");

    $modchild = $modparent->new(
        'NAME'     => 'Alpha::Beta',
        ABSTRACT => 'The quick brown fox',
        debug => 0,
    );
    isa_ok($modchild, "ExtUtils::ModuleMaker", "constructor is inheritable");
    is($modchild->{NAME}, 'Alpha::Beta', "child NAME '$modchild->{NAME}' is correct");
    is($modchild->{ABSTRACT}, 'The quick brown fox', "child ABSTRACT '$modchild->{ABSTRACT}' is correct");
    is($modchild->{AUTHOR}, q{Hilton Stallone}, "child AUTHOR '$modchild->{AUTHOR}' is correct");

    ok($modgrandchild  = $modchild->new(
        NAME => 'Gamma::Delta',
        ABSTRACT => 'The quick brown vixen',
        debug => 0,
    ), "call ExtUtils::ModuleMaker->new for Sample-Module");
    isa_ok($modgrandchild, "ExtUtils::ModuleMaker", "object is an EU::MM object");
    is($modgrandchild->{NAME}, 'Gamma::Delta', "grandchild NAME '$modgrandchild->{NAME}' is correct");
    is($modgrandchild->{ABSTRACT}, 'The quick brown vixen',
        "grandchild's explicitly coded ABSTRACT is correct");
    is($modgrandchild->{AUTHOR}, q{Hilton Stallone}, "grandchild AUTHOR '$modgrandchild->{AUTHOR}' is correct");

    ok(chdir $cwd, "Changed back to original directory");
}


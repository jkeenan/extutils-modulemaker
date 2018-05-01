# t/12_make-defaults.t
# tests of options to make modulemaker selections default personal values
use strict;
use warnings;
use Carp;
use Cwd;
use File::Spec;
use File::Temp qw(tempdir);
use Test::More qw(no_plan); # tests => 38;
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
    prepare_mockdirs
    basic_file_and_directory_tests
    license_text_test
    check_MakefilePL
) );
#use Data::Dump qw( dd pp );

my $cwd = cwd();

my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
local $ENV{HOME} = $home_dir;

my $personal_defaults_file = MockHomeDir::personal_defaults_file();
ok(-f $personal_defaults_file, "Able to create file $personal_defaults_file for testing");

{

=pod TestingModality:
    Suppress any Personal::Defaults currently installed on system.  Create a
new EU::MM object.  To be certain of values, require Testing::Defaults and
explicitly call the default_values() method from that package.  Build files
and verify structure and content with tests previously
developed.  Then, call make_selections_defaults().  That installs a
Personal::Defaults on system.
    Now create a second EU::MM object with new values for several keys.  Build
files from that object.  Use tests previously developed to analyze the content
of the Makefile.PL, the directory/file structure, etc.  Then do cleanup:
restore any Personal::Defaults which was originally on system.  Verify that
was done.

=cut

    my ($module_name, @components, $dist_name, $path_str, $module_file, @pred);

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    push @INC, File::Spec->catdir($home_dir, '.modulemaker');
    require ExtUtils::ModuleMaker::Personal::Defaults;
    my $testing_defaults_ref = ExtUtils::ModuleMaker::Personal::Defaults::default_values();

    my $obj1 = ExtUtils::ModuleMaker->new( %{$testing_defaults_ref} );
    isa_ok( $obj1, 'ExtUtils::ModuleMaker' );

    ok( $obj1->complete_build(), 'call complete_build()' );

    $module_name = $obj1->{NAME};
    @components = split(/::/, $module_name);
    $dist_name = join('-' => @components);
    $path_str = File::Spec->catdir(@components);

    basic_file_and_directory_tests($path_str);
    license_text_test($path_str, qr/Terms of Perl itself/);

    @pred = (
         q{EU::MM::Testing::Defaults},
        qq{lib\/EU\/MM\/Testing\/Defaults\.pm},
        qq{Hilton\\sStallone},
        qq{hiltons\@parliamentarypictures\.com},
        qq{Module\\sabstract\\s\\(<=\\s44\\scharacters\\)\\sgoes\\shere},
    );

    check_MakefilePL($path_str, \@pred);

    $obj1->make_selections_defaults();

    my $obj2 = ExtUtils::ModuleMaker->new(
        NAME    => q{Ackus::Frackus},
        AUTHOR  => q{Marilyn Shmarilyn},
        EMAIL   => q{marilyns@nineteenthcenturyfox.com},
        COMPACT => 1,
        SAVE_AS_DEFAULTS => 1,
    );
    isa_ok( $obj2, 'ExtUtils::ModuleMaker' );

    ok( $obj2->complete_build(), 'call complete_build()' );

    $module_name = $obj2->{NAME};
    @components = split(/::/, $module_name);
    $dist_name = join('-' => @components);
    $path_str = File::Spec->catdir(@components);
    $module_file = File::Spec->catfile(
        'lib', @components[0 .. ($#components - 1)], "$components[-1].pm");

    basic_file_and_directory_tests($dist_name);
    license_text_test($dist_name, qr/Terms of Perl itself/);

    @pred = (
        $module_name,
        $module_file,
        qq{Marilyn\\sShmarilyn},
        qq{marilyns\@nineteenthcenturyfox\.com},
        qq{Module\\sabstract\\s\\(<=\\s44\\scharacters\\)\\sgoes\\shere},
    );

    check_MakefilePL($dist_name, \@pred);

    do 'ExtUtils/ModuleMaker/Personal/Defaults.pm';
    my $obj3 = ExtUtils::ModuleMaker->new(
        NAME    => q{Hocus::Pocus},
    );
    isa_ok( $obj3, 'ExtUtils::ModuleMaker' );

    ok( $obj3->complete_build(), 'call complete_build()' );

    $module_name = $obj3->{NAME};
    @components = split(/::/, $module_name);
    $dist_name = join('-' => @components);
    $path_str = File::Spec->catdir(@components);
    $module_file = File::Spec->catfile(
        'lib', @components[0 .. ($#components - 1)], "$components[-1].pm");

    basic_file_and_directory_tests($dist_name);
    license_text_test($dist_name, qr/Terms of Perl itself/);

    @pred = (
        $module_name,
        $module_file,
        qq{Marilyn\\sShmarilyn},
        qq{marilyns\@nineteenthcenturyfox\.com},
        qq{Module\\sabstract\\s\\(<=\\s44\\scharacters\\)\\sgoes\\shere},
    );

    check_MakefilePL($dist_name, \@pred);
}


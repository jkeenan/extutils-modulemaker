# t/82_modulemaker.t
# tests of the modulemaker utility
use strict;
use warnings;
use Carp;
use Cwd;
use File::Spec;
use File::Temp qw(tempdir);
use Test::More;
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
    prepare_mockdirs
    basic_file_and_directory_tests
    license_text_test
    check_MakefilePL
) );
use Capture::Tiny qw( :all );
#    read_file_string
#    read_file_array
#    compact_build_tests

my $cwd = cwd();
{
    note("Set 1:  test against Testing::Defaults");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my (@components, $module_name, $dist_name, $path_str);
    my ($mf);
    @components = ( qw| EU MM Testing Defaults | );
    $module_name = join('::' => @components);
    $dist_name = join('-' => @components);
    $path_str = File::Spec->catdir(@components);
    $mf = join('/' => (
        'lib', @components[0 .. ($#components - 1)], "$components[-1].pm"));

    my ($abstract, $author, $cpanid, $organization, $website, $email);
    $abstract = "Module abstract (<= 44 characters) goes here";
    $author = "Hilton Stallone";
    $cpanid = 'RAMBO';
    $organization = 'Parliamentary Pictures';
    $website = 'http://parliamentarypictures.com';
    $email = 'hiltons\@parliamentarypictures.com';

    my @system_args = (
        $^X, qq{-I$cwd/blib/lib}, qq{$cwd/blib/script/modulemaker},
        '-I',
        '-n' . $module_name,
        '-a' . qq{$abstract},
        '-u' . $author,
        '-p' . $cpanid,
        '-o' . $organization,
        '-w' . $website,
        '-e' . $email,
    );
    my ($stdout, $stderr, @results);
    ($stdout, $stderr, @results) = capture { system(@system_args); };
    ok(! $results[0], "system call to modulemaker exited successfully");

    basic_file_and_directory_tests($path_str);
    license_text_test($path_str, qr/Terms of Perl itself/);

    my @pred = (
        $module_name,
        quotemeta($mf),
        quotemeta($author),
        quotemeta($email),
        quotemeta($abstract),
    );

    check_MakefilePL($path_str, \@pred);

    ok(chdir $cwd, "Able to change back to starting directory");
}

done_testing();

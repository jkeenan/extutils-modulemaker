# t/42_looselips.t
use strict;
use warnings;
use Carp;
use File::Spec;
use File::Temp qw(tempdir);
use Test::More tests => 19;
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::Licenses::Local' );
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
    prepare_mockdirs
    basic_file_and_directory_tests
    read_file_string
) );


{
    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my ($tdir, $filetext, $license);

    $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my ($mod);
    my $testmod = 'Beta';
    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);

    ok( $mod = ExtUtils::ModuleMaker->new(
            NAME           => $module_name,
            COMPACT        => 1,
            LICENSE        => 'looselips',
            COPYRIGHT_YEAR => 1899,
            AUTHOR         => "J E Keenan",
            ORGANIZATION   => "The World Wide Webby",
        ),
        "call ExtUtils::ModuleMaker->new for $dist_name"
    );

    ok($mod->complete_build(), "build files for Alpha::$testmod");

    basic_file_and_directory_tests($dist_name);

    $filetext = read_file_string(File::Spec->catfile($dist_name, 'LICENSE'));
    ok($filetext, 'Able to read LICENSE');

    like($filetext,
        qr/Copyright \(c\) 1899 The World Wide Webby\. All rights reserved\./,
        "correct copyright year and organization"
    );
    ok($license = $mod->get_license(), "license retrieved");
    like($license,
        qr/^={69}\s+={69}.*?={69}\s+={69}.*?={69}\s+={69}/s,
        "formatting for license and copyright found as expected"
    );
}


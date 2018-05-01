# t/22_debug.t
use strict;
use warnings;
use Carp;
use Cwd;
use File::Spec;
use File::Temp qw(tempdir);
use Test::More tests =>  61;
use_ok( 'IO::Capture::Stdout' );
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
    prepare_mockdirs
    compact_build_tests
) );
use lib ( qw| ./t/testlib | );
use_ok( 'MockHomeDir' );

my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
local $ENV{HOME} = $home_dir;

note("Case 1: No personal defaults file");

{
    my $cwd = cwd();
    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    #######################################################################

    my @components = qw| Sample Module Foo |;
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);

    my $capture = IO::Capture::Stdout->new();
    $capture->start();
    my $mod  = ExtUtils::ModuleMaker->new( 
        NAME        => $module_name,
        COMPACT        => 1,
        debug       => 1,
    );
    $capture->stop();
    ok($mod, "call ExtUtils::ModuleMaker->new for $dist_name");
    my $all_debug_output = join("\n" => $capture->read());
    like($all_debug_output, qr/AAA: \@INC/s, "Got expected debugging output");
    like($all_debug_output, qr/AAA: \@ISA/s, "Got expected debugging output");
    like($all_debug_output, qr/\s{4}abs/s, "Got expected debugging output");
    like($all_debug_output, qr/\s{4}flag\s+1/s, "Got expected debugging output");
    like($all_debug_output, qr/\s{4}home/s, "Got expected debugging output");
    like($all_debug_output, qr/\s{4}top/s, "Got expected debugging output");
    like($all_debug_output, qr/BBB: mmkr_dir_ref flag:\s+1/s, "Got expected debugging output");
    like($all_debug_output, qr/CCC: No Personal::Defaults module/s, "Got expected debugging output");
    like($all_debug_output, qr/DDD: \@ISA/s, "Got expected debugging output");
    like($all_debug_output, qr/EEE: AUTHOR: A. U. Thor/s, "Got expected debugging output");
    like($all_debug_output, qr/FFF: AUTHOR: A. U. Thor/s, "Got expected debugging output");
        
    ok( $mod->complete_build(), 'call complete_build()' );

    my ($module_file, $test_file) = compact_build_tests(\@components);

    ok(chdir $cwd, "Able to change back to starting directory");
}

note("Case 2: Personal defaults file present");

my $personal_defaults_file = MockHomeDir::personal_defaults_file();
ok(-f $personal_defaults_file, "Able to create file $personal_defaults_file for testing");

{
    my $cwd = cwd();
    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    #######################################################################

    my @components = qw| Sample Module Foo |;
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);

    my $capture = IO::Capture::Stdout->new();
    $capture->start();
    my $mod  = ExtUtils::ModuleMaker->new( 
        NAME        => $module_name,
        COMPACT        => 1,
        debug       => 1,
    );
    $capture->stop();
    ok($mod, "call ExtUtils::ModuleMaker->new for $dist_name");
    my $all_debug_output = join("\n" => $capture->read());
    like($all_debug_output, qr/AAA: \@INC/s, "Got expected debugging output");
    like($all_debug_output, qr/AAA: \@ISA/s, "Got expected debugging output");
    like($all_debug_output, qr/\s{4}abs/s, "Got expected debugging output");
    like($all_debug_output, qr/\s{4}flag\s+1/s, "Got expected debugging output");
    like($all_debug_output, qr/\s{4}home/s, "Got expected debugging output");
    like($all_debug_output, qr/\s{4}top/s, "Got expected debugging output");
    like($all_debug_output, qr/BBB: mmkr_dir_ref flag:\s+1/s, "Got expected debugging output");
    like($all_debug_output, qr/CCC: Personal::Defaults module.*?found/s, "Got expected debugging output");
    like($all_debug_output, qr/DDD: \@ISA/s, "Got expected debugging output");
    like($all_debug_output, qr/EEE: AUTHOR: Hilton Stallone/s, "Got expected debugging output");
    like($all_debug_output, qr/FFF: AUTHOR: Hilton Stallone/s, "Got expected debugging output");
        
    ok( $mod->complete_build(), 'call complete_build()' );

    my ($module_file, $test_file) = compact_build_tests(\@components);

    ok(chdir $cwd, "Able to change back to starting directory");
}


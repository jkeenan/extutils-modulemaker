# t/81-opts.t
# tests of ExtUtils::ModuleMaker::Opts methods
use strict;
use warnings;
use Test::More;
use_ok( 'ExtUtils::ModuleMaker::Opts' );
use IO::Capture::Stdout;
use IO::Capture::Stderr;

my ($eumm_package, $eumm_script, $opt);
$eumm_package = q{ExtUtils::ModuleMaker};
$eumm_script  = q{modulemaker};

{
    note("Case 1: Simplest possible use; INTERACTIVE declined");

    my $name = 'Alpha::Beta';
    local @ARGV = ('-n' => $name, '-I' => 0);

    $opt = ExtUtils::ModuleMaker::Opts->new( $eumm_package, $eumm_script );
    ok(defined $opt, "ExtUtils::ModuleMaker::Opts returned defined value");
    isa_ok($opt, 'ExtUtils::ModuleMaker::Opts');

    my %stan = $opt->get_standard_options();
    is($stan{NAME}, $name, "NAME correctly set to $name");
    ok(! exists $stan{ABSTRACT}, "No ABSTRACT set");

    like($stan{USAGE_MESSAGE},
        qr/^modulemaker.*Currently Supported Features/s,
        "Got USAGE MESSAGE"
    );
}

{
    note("Case 2: Simplest possible use; assign values to several options; INTERACTIVE declined");

    my $name = 'Alpha::Beta';
    my $abstract = 'Traverse the Greek alphabet';
    my $author = 'Chango Ta Beni';
    my $cpanid = 'CHANGO';
    my $email = 'chango_ta_beni@example.com';
    local @ARGV = (
        '-a' => $abstract,
        '-u' => $author,
        '-p' => $cpanid,
        '-e' => $email,
        '-n' => $name,
        '-I' => ''   # -I must go last
    );

    $opt = ExtUtils::ModuleMaker::Opts->new( $eumm_package, $eumm_script );
    ok(defined $opt, "ExtUtils::ModuleMaker::Opts returned defined value");
    isa_ok($opt, 'ExtUtils::ModuleMaker::Opts');

    my %stan = $opt->get_standard_options();
    is($stan{NAME}, $name, "NAME correctly set to $name");
    is($stan{ABSTRACT}, $abstract, "ABSTRACT correctly set to $abstract");
    is($stan{AUTHOR}, $author, "AUTHOR correctly set to $author");
    is($stan{CPANID}, $cpanid, "CPANID correctly set to $cpanid");
    is($stan{EMAIL}, $email, "EMAIL correctly set to $email");
}

{
    note("Case 3: Simplest possible use; mix options with take/do not take values (grouped); INTERACTIVE declined");

    #getopts( "hqsCIPVcn:a:v:l:u:p:o:w:e:t:r:d:b:", \%opts );
    my $name = 'Alpha::Beta';
    my $abstract = 'Traverse the Greek alphabet';
    my $author = 'Chango Ta Beni';
    my $cpanid = 'CHANGO';
    my $email = 'chango_ta_beni@example.com';
    local @ARGV = (
        '-a' => $abstract,
        '-u' => $author,
        '-p' => $cpanid,
        '-e' => $email,
        '-n' => $name,
        '-cVPq',
        '-I' => ''   # -I must go last
    );

    $opt = ExtUtils::ModuleMaker::Opts->new( $eumm_package, $eumm_script );
    ok(defined $opt, "ExtUtils::ModuleMaker::Opts returned defined value");
    isa_ok($opt, 'ExtUtils::ModuleMaker::Opts');

    my %stan = $opt->get_standard_options();
    is($stan{NAME}, $name, "NAME correctly set to $name");
    is($stan{ABSTRACT}, $abstract, "ABSTRACT correctly set to $abstract");
    is($stan{AUTHOR}, $author, "AUTHOR correctly set to $author");
    is($stan{CPANID}, $cpanid, "CPANID correctly set to $cpanid");
    is($stan{EMAIL}, $email, "EMAIL correctly set to $email");
    ok($stan{COMPACT}, "COMPACT build requested");
    ok($stan{VERBOSE}, "VERBOSE output requested");
    ok(!$stan{NEED_POD}, "NEED_POD output requested");
    ok(!$stan{NEED_NEW_METHOD}, "NEED_NEW_METHOD output requested");
}

{
    note("Case 4: Simplest possible use; mix options with take/do not take values (ungrouped); INTERACTIVE declined");

    my $name = 'Alpha::Beta';
    my $abstract = 'Traverse the Greek alphabet';
    my $author = 'Chango Ta Beni';
    my $cpanid = 'CHANGO';
    my $email = 'chango_ta_beni@example.com';
    my $organization = 'World Wide Web, Inc.';
    my $website = 'http://example.com';
    my $permissions = '0711';
    my $version = '0.03';
    my $license = 'apache';
    local @ARGV = (
        '-a' => $abstract,
        '-u' => $author,
        '-p' => $cpanid,
        '-e' => $email,
        '-n' => $name,
        '-o' => $organization,
        '-w' => $website,
        '-r' => $permissions,
        '-v' => $version,
        '-l' => $license,
        '-c',
        '-C',  # Changes in POD
        '-V',
        '-b',
        '-I' => ''   # -I must go last
    );

    $opt = ExtUtils::ModuleMaker::Opts->new( $eumm_package, $eumm_script );
    ok(defined $opt, "ExtUtils::ModuleMaker::Opts returned defined value");
    isa_ok($opt, 'ExtUtils::ModuleMaker::Opts');

    my %stan = $opt->get_standard_options();
    is($stan{NAME}, $name, "NAME correctly set to $name");
    is($stan{ABSTRACT}, $abstract, "ABSTRACT correctly set to $abstract");
    is($stan{AUTHOR}, $author, "AUTHOR correctly set to $author");
    is($stan{CPANID}, $cpanid, "CPANID correctly set to $cpanid");
    is($stan{EMAIL}, $email, "EMAIL correctly set to $email");
    is($stan{ORGANIZATION}, $organization, "ORGANIZATION correctly set to $organization");
    is($stan{WEBSITE}, $website, "WEBSITE correctly set to $website");
    is($stan{PERMISSIONS}, $permissions, "PERMISSIONS correctly set to $permissions");
    is($stan{VERSION}, $version, "VERSION correctly set to $version");
    is($stan{LICENSE}, $license, "LICENSE correctly set to $license");
    ok($stan{COMPACT}, "COMPACT build requested");
    ok($stan{CHANGES_IN_POD}, "CHANGES_IN_POD build requested");
    ok($stan{VERBOSE}, "VERBOSE output requested");
    ok($stan{BUILD_SYSTEM}, "BUILD_SYSTEM set to true; will request Module::Build");
}

{
    note("Set 5:  test help switch '-h'");

    local @ARGV = ( '-h' );

	my $capture = IO::Capture::Stdout->new();
    $capture->start();
    my $opt =  ExtUtils::ModuleMaker::Opts->new( $eumm_package, $eumm_script );
    $capture->stop();
    ok(! $opt, "system call to modulemaker exited successfully");

    my $stdout = join("\n" => $capture->read());
    like($stdout, qr/^modulemaker \[-CIPVch\]/s,
        "Got expected start of Usage message");
    like($stdout, qr/Currently Supported Features/s,
        "Got expected middle of Usage message");
    like($stdout, qr/modulemaker\s+ExtUtils::ModuleMaker\sversion:\s+\d\.\d{2}$/s,
        "Got expected end of Usage message");
}

{
    note("Set 6:  test absence of switch: '-n'");

    local @ARGV = ( '-cI' );

    my $opt = ExtUtils::ModuleMaker::Opts->new( $eumm_package, $eumm_script );
    my %stan = $opt->get_standard_options();
    ok(! $stan{NAME}, "NAME not set");
    ok($stan{COMPACT}, "COMPACT build requested");
}

done_testing();

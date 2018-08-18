# t/91-miscargs.t
# tests of miscellaneous arguments passed to constructor
use strict;
use warnings;
use Carp;
use Cwd;
use File::Spec;
use File::Temp qw(tempdir);
use Test::More;
use_ok( 'IO::Capture::Stdout' );
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
    prepare_mockdirs
    basic_file_and_directory_tests
    license_text_test
    read_file_string
    read_file_array
    compact_build_tests
) );

my $cwd = cwd();
{
    note("Set 1:  Test VERBOSE => 1 to make sure that logging messages\n" .
    "  note each directory and file created; Compact top directory.");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $testmod = 'Beta';
    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);

    my ($mod);
    ok( $mod = ExtUtils::ModuleMaker->new(
            NAME           => $module_name,
            COMPACT        => 1,
            VERBOSE        => 1,
        ),
        "call ExtUtils::ModuleMaker->new for $dist_name"
    );

    my ($capture, %count);
    $capture = IO::Capture::Stdout->new();
    $capture->start();
    ok( $mod->complete_build(), 'call complete_build()' );
    $capture->stop();
    for my $l ($capture->read()) {
        $count{'mkdir'}++ if $l =~ /^mkdir/;
        $count{'writing'}++ if $l =~ /^writing file/;
    }
    is($count{'mkdir'}, 5, "correct no. of directories created announced verbosely");
    is($count{'writing'}, 8, "correct no. of files created announced verbosely");

    my ($module_file, $test_file) = compact_build_tests(\@components);


    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set 2:  Test VERBOSE => 1 to make sure that logging messages\n" .
    "  note each directory and file created. Non-compact top directory.");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $testmod = 'Gamma';
    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    my $path_str = File::Spec->catdir(@components);

    my ($mod);
    ok( $mod = ExtUtils::ModuleMaker->new(
            NAME           => $module_name,
            COMPACT        => 0,
            VERBOSE        => 1,
       ),
       "call ExtUtils::ModuleMaker->new for $dist_name"
    );
    my ($capture, %count);
    $capture = IO::Capture::Stdout->new();
    $capture->start();
    ok( $mod->complete_build(), 'call complete_build()' );
    $capture->stop();
    for my $l ($capture->read()) {
        $count{'mkdir'}++ if $l =~ /^mkdir/;
        $count{'writing'}++ if $l =~ /^writing file/;
    }
    is($count{'mkdir'}, 6, "correct no. of directories created announced verbosely");
    is($count{'writing'}, 8, "correct no. of files created announced verbosely");

    basic_file_and_directory_tests($path_str);
    license_text_test($path_str, qr/Terms of Perl itself/);

    my $module_file = File::Spec->catfile(
        @components,
        'lib',
        @components[0 .. ($#components - 1)],
        "$components[-1].pm",
    );
    my $test_file = File::Spec->catfile(
        @components,
        't',
        '001_load.t',
    );
    for my $ff ($module_file, $test_file) {
        ok( -f $ff, "$ff exists");
    }
    my ($filetext);
    ok($filetext = read_file_string(File::Spec->catfile(@components, 'Makefile.PL')),
        'Able to read Makefile.PL');

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set 3:  Tests of dump_keys() method.");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $testmod = 'Tau';
    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    my $path_str = File::Spec->catdir(@components);

    my ($mod);
    ok( $mod = ExtUtils::ModuleMaker->new(
            NAME           => $module_name,
            COMPACT        => 0,
            VERBOSE        => 1,
            ABSTRACT       => "Tau's the time for Perl",
        ),
        "call ExtUtils::ModuleMaker->new for $dist_name"
    );

    my $dump;
    ok( $dump = $mod->dump_keys(qw| NAME ABSTRACT |),
        'call dump_keys()' );
    my @dumplines = split(/\n/, $dump);
    my $keys_shown_flag = 0;
    for my $m ( @dumplines ) {
        $keys_shown_flag++ if $m =~ /^\s+'(NAME|ABSTRACT)/;
    } #'
    is($keys_shown_flag, 2,
        "keys intended to be shown were shown");

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set 4:  Tests of dump_keys_except() method.");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $testmod = 'Rho';
    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    my $path_str = File::Spec->catdir(@components);

    my ($mod);
    ok( $mod = ExtUtils::ModuleMaker->new(
            NAME           => $module_name,
            COMPACT        => 0,
            VERBOSE        => 1,
        ),
        "call ExtUtils::ModuleMaker->new for $dist_name"
    );

    my $dump;
    ok( $dump = $mod->dump_keys_except(qw| LicenseParts USAGE_MESSAGE |),
        'call dump_keys_except()' );
    my @dumplines = split(/\n/, $dump);
    my $excluded_keys_flag = 0;
    for my $m ( @dumplines ) {
        $excluded_keys_flag++ if $m =~ /^\s+'(LicenseParts|USAGE_MESSAGE)/;
    } #'
    is($excluded_keys_flag, 0,
        "keys intended to be excluded were excluded");

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set 5:  Test of NEED_POD option");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $testmod = 'Phi';
    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    my $path_str = File::Spec->catdir(@components);

    my ($mod);
    ok( $mod = ExtUtils::ModuleMaker->new(
            NAME           => $module_name,
            COMPACT        => 1,
            NEED_POD       => 0,
        ),
        "call ExtUtils::ModuleMaker->new for $dist_name"
    );

    ok( $mod->complete_build(), 'call complete_build()' );

    my ($module_file, $test_file) = compact_build_tests(\@components);

    my (@filelines);
    ok(@filelines = read_file_array($module_file),
        'Able to read module into array');
    is( (grep {/^=(head|cut)/} @filelines), 0,
        "no POD correctly detected in module");

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set 6:  Tests of NEED_NEW_METHOD option");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $testmod = 'Chi';
    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    my $path_str = File::Spec->catdir(@components);

    my ($mod);
    ok( $mod = ExtUtils::ModuleMaker->new(
            NAME           => $module_name,
            COMPACT         => 1,
            NEED_NEW_METHOD => 0,
        ),
        "call ExtUtils::ModuleMaker->new for $dist_name"
    );

    ok( $mod->complete_build(), 'call complete_build()' );

    my ($module_file, $test_file) = compact_build_tests(\@components);

    my (@filelines);
    is( (grep {/^sub new/} @filelines), 0,
        "no sub new() correctly detected in module");

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set 7:  Tests of NEED_POD and NEED_NEW_METHOD options");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $testmod = 'Xi';
    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    my $path_str = File::Spec->catdir(@components);

    my ($mod);
    ok( $mod = ExtUtils::ModuleMaker->new(
            NAME           => $module_name,
            COMPACT         => 1,
            NEED_POD        => 0,
            NEED_NEW_METHOD => 0,
        ),
        "call ExtUtils::ModuleMaker->new for $dist_name"
    );

    ok( $mod->complete_build(), 'call complete_build()' );

    my ($module_file, $test_file) = compact_build_tests(\@components);

    my (@filelines);
    is( (grep {/^(sub new|=(head|cut))/} @filelines), 0,
        "no sub new() or POD correctly detected in module");

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set #8:  Test of EXTRA_MODULES Option");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $testmod = 'Sigma';
    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    my $path_str = File::Spec->catdir(@components);

    my ($mod);
    ok( $mod = ExtUtils::ModuleMaker->new(
            NAME           => $module_name,
            COMPACT        => 1,
            EXTRA_MODULES  => [
                { NAME => "Alpha::${testmod}::Gamma" },
                { NAME => "Alpha::${testmod}::Delta" },
                { NAME => "Alpha::${testmod}::Gamma::Epsilon" },
            ],
        ),
        "call ExtUtils::ModuleMaker->new for $dist_name"
    );

    ok( $mod->complete_build(), 'call complete_build()' );

    my ($module_file, $test_file) = compact_build_tests(\@components);

    ok( -d, "directory $_ exists" ) for (
        File::Spec->catdir($dist_name, 'lib', 'Alpha'),
        File::Spec->catdir($dist_name, 'lib', 'Alpha', $testmod),
        File::Spec->catdir($dist_name, 'lib', 'Alpha', $testmod, 'Gamma'),
    );
    ok( -f, "file $_ exists" )
        for (
            File::Spec->catfile($dist_name, 'lib', 'Alpha', "${testmod}.pm"),
            File::Spec->catfile($dist_name, 'lib', 'Alpha', $testmod, 'Gamma.pm'),
            File::Spec->catfile($dist_name, 'lib', 'Alpha', $testmod, 'Delta.pm'),
            File::Spec->catfile($dist_name, 'lib', 'Alpha', $testmod, 'Gamma', 'Epsilon.pm'),
            File::Spec->catfile($dist_name, 't', '001_load.t'),
            File::Spec->catfile($dist_name, 't', '002_load.t'),
            File::Spec->catfile($dist_name, 't', '003_load.t'),
            File::Spec->catfile($dist_name, 't', '004_load.t'),
        );

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set 9:  Test VERSION for value other than 0.01;\n  make sure it is quoted in .pm file.");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $testmod = 'Beta';
    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    my $path_str = File::Spec->catdir(@components);

    my ($mod);
    ok( $mod = ExtUtils::ModuleMaker->new(
            NAME           => $module_name,
            COMPACT        => 1,
            VERSION        => q{0.3},
        ),
        "call ExtUtils::ModuleMaker->new for $dist_name"
    );

    ok( $mod->complete_build(), 'call complete_build()' );

    my ($module_file, $test_file) = compact_build_tests(\@components);

    my ($filetext);
    ok($filetext = read_file_string($module_file),
            "Able to read $module_file");
    like($filetext, qr/\$VERSION\s+=\s+'0\.3'/,
        "VERSION number is correct and properly quoted");

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set # 10:  Test of EXTRA_MODULES Option\n  with all tests in a single file");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $testmod = 'Sigma';
    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    my $path_str = File::Spec->catdir(@components);

    my ($mod);
    ok( $mod = ExtUtils::ModuleMaker->new(
            NAME           => $module_name,
            COMPACT        => 1,
            EXTRA_MODULES  => [
                { NAME => "Alpha::${testmod}::Gamma" },
                { NAME => "Alpha::${testmod}::Delta" },
                { NAME => "Alpha::${testmod}::Gamma::Epsilon" },
            ],
            EXTRA_MODULES_SINGLE_TEST_FILE => 1,
        ),
        "call ExtUtils::ModuleMaker->new for $dist_name"
    );

    ok( $mod->complete_build(), 'call complete_build()' );

    my ($module_file, $test_file) = compact_build_tests(\@components);

    ok( -d, "directory $_ exists" ) for (
        File::Spec->catdir($dist_name, 'lib', 'Alpha'),
        File::Spec->catdir($dist_name, 'lib', 'Alpha', $testmod),
        File::Spec->catdir($dist_name, 'lib', 'Alpha', $testmod, 'Gamma'),
    );
    ok( -f, "file $_ exists" )
        for (
            File::Spec->catfile($dist_name, 'lib', 'Alpha', "${testmod}.pm"),
            File::Spec->catfile($dist_name, 'lib', 'Alpha', $testmod, 'Gamma.pm'),
            File::Spec->catfile($dist_name, 'lib', 'Alpha', $testmod, 'Delta.pm'),
            File::Spec->catfile($dist_name, 'lib', 'Alpha', $testmod, 'Gamma', 'Epsilon.pm'),
            File::Spec->catfile($dist_name, 't', '001_load.t'),
        );
    my $number_line = q{use Test::More tests => 4;};
    my ($filetext);
    $filetext = read_file_string(File::Spec->catfile($dist_name, 't', '001_load.t'));
    ok( (index($filetext, $number_line)) > -1,
        "test file lists predicted number in plan");
    my @use = qw(
            Alpha::Sigma
            Alpha::Sigma::Gamma
            Alpha::Sigma::Delta
            Alpha::Sigma::Gamma::Epsilon
    );
    foreach my $f (@use) {
        my $newstr = "    use_ok( '$f' );";
        ok( (index($filetext, $newstr)) > -1,
            "test file contains use_ok for $f");
    }

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set # 11:  Test of EXTRA_MODULES Option\n  with test names derived from module names");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $testmod = 'Sigma';
    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    my $path_str = File::Spec->catdir(@components);

    my ($mod);
    ok( $mod = ExtUtils::ModuleMaker->new(
            NAME           => $module_name,
            COMPACT        => 1,
            EXTRA_MODULES  => [
                { NAME => "Alpha::${testmod}::Gamma" },
                { NAME => "Alpha::${testmod}::Delta" },
                { NAME => "Alpha::${testmod}::Gamma::Epsilon" },
            ],
            TEST_NAME_DERIVED_FROM_MODULE_NAME => 1,
            TEST_NUMBER_FORMAT  => undef,
        ),
        "call ExtUtils::ModuleMaker->new for $dist_name"
    );

    ok( $mod->complete_build(), 'call complete_build()' );

    #my ($module_file, $test_file) = compact_build_tests(\@components);

    ok( -d, "directory $_ exists" ) for (
        File::Spec->catdir($dist_name, 'lib', 'Alpha'),
        File::Spec->catdir($dist_name, 'lib', 'Alpha', $testmod),
        File::Spec->catdir($dist_name, 'lib', 'Alpha', $testmod, 'Gamma'),
    );
    ok( -f, "file $_ exists" )
        for (
            File::Spec->catfile($dist_name, 'lib', 'Alpha', "${testmod}.pm"),
            File::Spec->catfile($dist_name, 'lib', 'Alpha', $testmod, 'Gamma.pm'),
            File::Spec->catfile($dist_name, 'lib', 'Alpha', $testmod, 'Delta.pm'),
            File::Spec->catfile($dist_name, 'lib', 'Alpha', $testmod, 'Gamma', 'Epsilon.pm'),
            File::Spec->catfile($dist_name, 't', "Alpha_${testmod}.t"),
            File::Spec->catfile($dist_name, 't', "Alpha_${testmod}_Gamma.t"),
            File::Spec->catfile($dist_name, 't', "Alpha_${testmod}_Delta.t"),
            File::Spec->catfile($dist_name, 't', "Alpha_${testmod}_Gamma_Epsilon.t"),
        );

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set # 12:  Test of EXTRA_MODULES Option\n" .
       "  with all tests in a single file, with no number in test name");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $testmod = 'Sigma';
    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    my $path_str = File::Spec->catdir(@components);

    my ($mod);
    ok( $mod = ExtUtils::ModuleMaker->new(
            NAME           => $module_name,
            COMPACT        => 1,
            EXTRA_MODULES  => [
                { NAME => "Alpha::${testmod}::Gamma" },
                { NAME => "Alpha::${testmod}::Delta" },
                { NAME => "Alpha::${testmod}::Gamma::Epsilon" },
            ],
            EXTRA_MODULES_SINGLE_TEST_FILE => 1,
            TEST_NUMBER_FORMAT  => undef,
        ),
        "call ExtUtils::ModuleMaker->new for $dist_name"
    );

    ok( $mod->complete_build(), 'call complete_build()' );

    #my ($module_file, $test_file) = compact_build_tests(\@components);

    ok( -d, "directory $_ exists" ) for (
        File::Spec->catdir($dist_name, 'lib', 'Alpha'),
        File::Spec->catdir($dist_name, 'lib', 'Alpha', $testmod),
        File::Spec->catdir($dist_name, 'lib', 'Alpha', $testmod, 'Gamma'),
    );
    ok( -f, "file $_ exists" )
        for (
            File::Spec->catfile($dist_name, 'lib', 'Alpha', "${testmod}.pm"),
            File::Spec->catfile($dist_name, 'lib', 'Alpha', $testmod, 'Gamma.pm'),
            File::Spec->catfile($dist_name, 'lib', 'Alpha', $testmod, 'Delta.pm'),
            File::Spec->catfile($dist_name, 'lib', 'Alpha', $testmod, 'Gamma', 'Epsilon.pm'),
            File::Spec->catfile($dist_name, 't', "load.t"),
    );

    my ($filetext);
    $filetext = read_file_string(File::Spec->catfile($dist_name, 't', "load.t"));
    my $number_line = q{use Test::More tests => 4;};
    ok( (index($filetext, $number_line)) > -1,
        "test file lists predicted number in plan");
    my @use = qw(
            Alpha::Sigma
            Alpha::Sigma::Gamma
            Alpha::Sigma::Delta
            Alpha::Sigma::Gamma::Epsilon
    );
    foreach my $f (@use) {
        my $newstr = "    use_ok( '$f' );";
        ok( (index($filetext, $newstr)) > -1,
            "test file contains use_ok for $f");
    }

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set 13:  Test of INCLUDE_MANIFEST_SKIP option");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $testmod = 'Phi';
    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    my $path_str = File::Spec->catdir(@components);

    my ($mod);
    ok( $mod = ExtUtils::ModuleMaker->new(
            NAME           => $module_name,
            COMPACT        => 1,
            INCLUDE_MANIFEST_SKIP => 1,
        ),
        "call ExtUtils::ModuleMaker->new for $dist_name"
    );

    ok( $mod->complete_build(), 'call complete_build()' );

    my ($module_file, $test_file) = compact_build_tests(\@components);

    ok( -f, "file $_ exists" )
        for (
            File::Spec->catfile($dist_name, 'lib', 'Alpha', "${testmod}.pm"),
            File::Spec->catfile($dist_name, 't', "001_load.t"),
            File::Spec->catfile($dist_name, 'MANIFEST.SKIP'),
        );

    my $mskip_str = read_file_string(File::Spec->catfile($dist_name, 'MANIFEST.SKIP'));
    like($mskip_str, qr/\^\\\.travis\.yml/s,
        ".travis.yml located in MANIFEST.SKIP");
    like($mskip_str, qr/\^\\\.appveyor\.yml/s,
        ".appveyor.yml located in MANIFEST.SKIP");

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set 14:  Test of (negating) INCLUDE_TODO option");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $testmod = 'Phi';
    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    my $path_str = File::Spec->catdir(@components);

    my ($mod);
    ok( $mod = ExtUtils::ModuleMaker->new(
            NAME           => $module_name,
            COMPACT        => 1,
            INCLUDE_TODO   => 0,
        ),
        "call ExtUtils::ModuleMaker->new for $dist_name"
    );

    ok( $mod->complete_build(), 'call complete_build()' );

    my ($module_file, $test_file) = compact_build_tests(\@components);

    ok( ! -f, "file $_ does not exists" )
        for (
            File::Spec->catfile($dist_name, 'TODO'),
        );

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set 15:  Test of INCLUDE_POD_COVERAGE_TEST and INCLUDE_POD_TEST options");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $testmod = 'Phi';
    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    my $path_str = File::Spec->catdir(@components);

    my ($mod);
    ok( $mod = ExtUtils::ModuleMaker->new(
            NAME           => $module_name,
            COMPACT                     => 1,
            INCLUDE_POD_COVERAGE_TEST   => 1,
            INCLUDE_POD_TEST            => 1,
        ),
        "call ExtUtils::ModuleMaker->new for $dist_name"
    );

    ok( $mod->complete_build(), 'call complete_build()' );

    my ($module_file, $test_file) = compact_build_tests(\@components);

    ok( -f, "file $_ exists" )
        for (
            File::Spec->catfile($dist_name, 't', 'pod-coverage.t'),
            File::Spec->catfile($dist_name, 't', 'pod.t'),
        );

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set 16:  Test of (negation of) INCLUDE_LICENSE option");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $testmod = 'Xi';
    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    my $path_str = File::Spec->catdir(@components);

    my ($mod);
    ok( $mod = ExtUtils::ModuleMaker->new(
            NAME            => $module_name,
            COMPACT         => 1,
            INCLUDE_LICENSE => 0,
        ),
        "call ExtUtils::ModuleMaker->new for $dist_name"
    );

    ok( $mod->complete_build(), 'call complete_build()' );

    ok( ! -f, "file $_ does not exists" )
        for (
            File::Spec->catfile($dist_name, 'LICENSE'),
        );

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set 17:  Test of (negating) INCLUDE_SCRIPTS_DIRECTORY option");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $testmod = 'Phi';
    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    my $path_str = File::Spec->catdir(@components);

    my ($mod);
    ok( $mod = ExtUtils::ModuleMaker->new(
            NAME           => $module_name,
            COMPACT        => 1,
            INCLUDE_SCRIPTS_DIRECTORY => 0,
        ),
        "call ExtUtils::ModuleMaker->new for $dist_name"
    );

    ok( $mod->complete_build(), 'call complete_build()' );

    my ($module_file, $test_file) = compact_build_tests(\@components);

    ok( ! -d, "directory $_ does not exist" ) for (
        File::Spec->catdir($dist_name, 'scripts'),
    );

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set 18:  Test of INCLUDE_FILE_IN_PM option");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $testmod = 'Kappa';
    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    my $path_str = File::Spec->catdir(@components);

    my ($mod);
    ok( $mod = ExtUtils::ModuleMaker->new(
            NAME           => $module_name,
            COMPACT        => 1,
            EXTRA_MODULES  => [
                { NAME => "Alpha::${testmod}::Gamma" },
                { NAME => "Alpha::${testmod}::Delta" },
                { NAME => "Alpha::${testmod}::Gamma::Epsilon" },
            ],
            INCLUDE_FILE_IN_PM => "$cwd/t/testlib/arbitrary.txt",
        ),
        "call ExtUtils::ModuleMaker->new for $dist_name"
    );

    ok( $mod->complete_build(), 'call complete_build()' );

    my ($module_file, $test_file) = compact_build_tests(\@components);

    ok( -d, "directory $_ exists" ) for (
        File::Spec->catdir($dist_name, 'lib', 'Alpha'),
        File::Spec->catdir($dist_name, 'lib', 'Alpha', $testmod),
        File::Spec->catdir($dist_name, 'lib', 'Alpha', $testmod, 'Gamma'),
    );
    my @pm_pred = (
        File::Spec->catfile($dist_name, 'lib', 'Alpha', "${testmod}.pm"),
        File::Spec->catfile($dist_name, 'lib', 'Alpha', $testmod, 'Gamma.pm'),
        File::Spec->catfile($dist_name, 'lib', 'Alpha', $testmod, 'Delta.pm'),
        File::Spec->catfile($dist_name, 'lib', 'Alpha', $testmod, 'Gamma', 'Epsilon.pm'),
    );
    ok( -f, "file $_ exists" )
        for (
            @pm_pred,
            File::Spec->catfile($dist_name, 't', '001_load.t'),
            File::Spec->catfile($dist_name, 't', '002_load.t'),
            File::Spec->catfile($dist_name, 't', '003_load.t'),
            File::Spec->catfile($dist_name, 't', '004_load.t'),
    );

    for my $pm (@pm_pred) {
        my $line = read_file_string($pm);
        like($line, qr<=pod.+INCLUDE_FILE_IN_PM.+sub marine \{}>s,
            "$pm contains pod header, key-value pair, sub");
    }

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set 19:  Set CPANID to empty string and verify that no blank line is\n" .
    "  added to the .pm file author info section.");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $testmod = 'Lambda';
    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    my $path_str = File::Spec->catdir(@components);

    my ($mod);
    ok( $mod = ExtUtils::ModuleMaker->new(
            NAME           => $module_name,
            COMPACT        => 1,
            AUTHOR         => 'Phineas T. Bluster',
            CPANID         => q{},
            ORGANIZATION   => 'Peanut Gallery',
            WEBSITE        => 'http://www.anonymous.com/~phineas',
            EMAIL          => 'phineas@anonymous.com',
        ),
        "call ExtUtils::ModuleMaker->new for $dist_name"
    );

    ok( $mod->complete_build(), 'call complete_build()' );

    my ($module_file, $test_file) = compact_build_tests(\@components);

    my @pm_pred = (
        File::Spec->catfile($dist_name, 'lib', 'Alpha', "${testmod}.pm"),
    );
    my $line = read_file_string($pm_pred[0]);
    ok($line =~ m|
            Phineas\sT\.\sBluster\n
            [ \t]+Peanut\sGallery\n
            \s+phineas\@anonymous\.com\n
            \s+http:\/\/www\.anonymous\.com\/~phineas
        |xs,
        'POD contains correct author info -- no CPANID');

    ok(chdir $cwd, "Able to change back to starting directory");
}


{
    note("Set 20:  Set ORGANIZATION to empty string and verify that no blank line is\n" .
    "  added to the .pm file author info section.");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $testmod = 'Lambda';
    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    my $path_str = File::Spec->catdir(@components);

    my ($mod);
    ok( $mod = ExtUtils::ModuleMaker->new(
            NAME           => $module_name,
            COMPACT        => 1,
            AUTHOR         => 'Phineas T. Bluster',
            CPANID         => 'PTBLUSTER',
            ORGANIZATION   => q{},
            WEBSITE        => 'http://www.anonymous.com/~phineas',
            EMAIL          => 'phineas@anonymous.com',
        ),
        "call ExtUtils::ModuleMaker->new for $dist_name"
    );

    ok( $mod->complete_build(), 'call complete_build()' );

    my ($module_file, $test_file) = compact_build_tests(\@components);

    my @pm_pred = (
        File::Spec->catfile($dist_name, 'lib', 'Alpha', "${testmod}.pm"),
    );
    my $line = read_file_string($pm_pred[0]);
    ok($line =~ m|
            Phineas\sT\.\sBluster\n
            \s+CPAN\sID:\s+PTBLUSTER\n
            [ \t]+phineas\@anonymous\.com\n
            \s+http:\/\/www\.anonymous\.com\/~phineas
        |xs,
        'POD contains correct author info -- no ORGANIZATION');

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set 21:  Set WEBSITE to empty string and verify that no blank line is\n" .
    "  added to the .pm file author info section.");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $testmod = 'Lambda';
    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    my $path_str = File::Spec->catdir(@components);

    my ($mod);
    ok( $mod = ExtUtils::ModuleMaker->new(
            NAME           => $module_name,
            COMPACT        => 1,
            AUTHOR         => 'Phineas T. Bluster',
            CPANID         => 'PTBLUSTER',
            ORGANIZATION   => 'Peanut Gallery',
            WEBSITE        => q{},
            EMAIL          => 'phineas@anonymous.com',
        ),
        "call ExtUtils::ModuleMaker->new for $dist_name"
    );

    ok( $mod->complete_build(), 'call complete_build()' );

    my ($module_file, $test_file) = compact_build_tests(\@components);

    my @pm_pred = (
        File::Spec->catfile($dist_name, 'lib', 'Alpha', "${testmod}.pm"),
    );
    my $line = read_file_string($pm_pred[0]);
    ok($line =~ m|
            Phineas\sT\.\sBluster\n
            \s+CPAN\sID:\s+PTBLUSTER\n
            \s+Peanut\sGallery\n
            \s+phineas\@anonymous\.com
        |xs,
            'POD contains correct author info -- no WEBSITE');

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set 22: Test insertion of warnings in .pm files.");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $testmod = 'Lambda';
    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    my $path_str = File::Spec->catdir(@components);

    my ($mod);
    ok( $mod = ExtUtils::ModuleMaker->new(
            NAME           => $module_name,
            COMPACT        => 1,
            AUTHOR         => 'Phineas T. Bluster',
            CPANID         => 'PTBLUSTER',
            ORGANIZATION   => 'Peanut Gallery',
            EMAIL          => 'phineas@anonymous.com',
            INCLUDE_WARNINGS => 1,
        ),
        "call ExtUtils::ModuleMaker->new for $dist_name"
    );

    ok( $mod->complete_build(), 'call complete_build()' );

    my ($module_file, $test_file) = compact_build_tests(\@components);

    my @pm_pred = (
        File::Spec->catfile($dist_name, 'lib', 'Alpha', "${testmod}.pm"),
    );
    my $line = read_file_string($pm_pred[0]);
    ok($line =~ m|
            use\sstrict;\n
            use\swarnings;\n
        |xs,
        q<.pm file contains 'use warnings;'>);

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set 23: Test insertion of version control ID line in .pm files.");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $testmod = 'Lambda';
    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    my $path_str = File::Spec->catdir(@components);

    my ($mod);
    ok( $mod = ExtUtils::ModuleMaker->new(
            NAME           => $module_name,
            COMPACT        => 1,
            AUTHOR         => 'Phineas T. Bluster',
            CPANID         => 'PTBLUSTER',
            ORGANIZATION   => 'Peanut Gallery',
            EMAIL          => 'phineas@anonymous.com',
            INCLUDE_ID_LINE => 1,
        ),
        "call ExtUtils::ModuleMaker->new for $dist_name"
    );

    ok( $mod->complete_build(), 'call complete_build()' );

    my ($module_file, $test_file) = compact_build_tests(\@components);

    my @pm_pred = (
        File::Spec->catfile($dist_name, 'lib', 'Alpha', "${testmod}.pm"),
    );
    my $line = read_file_string($pm_pred[0]);
    ok($line =~ m|
            #$Id#\n
            use\sstrict;\n
        |xs,
        q<.pm file contains 'Id' string>);

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set 24: https://rt.cpan.org/Ticket/Display.html?id=15563:\n  Suppress printing of CPANID, WEBSITE or ORGANIZATION");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my ($testmod, @components, $module_name, $dist_name, $path_str);
    my (%these_args);
    my ($module_file, $test_file, $pm_pred, $line);

    my %sample_args = (
        COMPACT        => 1,
        AUTHOR         => 'Phineas T. Bluster',
        EMAIL          => 'phineas@anonymous.com',
        CPANID         => 'PTBLUSTER',
        WEBSITE        => 'http://example.com',
        ORGANIZATION   => 'Peanut Gallery',
    );

    note("    24a:  WEBSITE omitted; default to dummy copy");
    $testmod = 'Epsilon';
    @components = ( 'Alpha', $testmod );
    $module_name = join('::' => @components);
    $dist_name = join('-' => @components);
    $path_str = File::Spec->catdir(@components);

    %these_args = (
        NAME           => $module_name,
        %sample_args,
    );
    delete $these_args{WEBSITE};

    my $mod1 = ExtUtils::ModuleMaker->new(%these_args);
    ok($mod1, "call ExtUtils::ModuleMaker->new for $dist_name");

    ok( $mod1->complete_build(), 'call complete_build()' );

    ($module_file, $test_file) = compact_build_tests(\@components);

    $pm_pred = (
        File::Spec->catfile($dist_name, 'lib', 'Alpha', "${testmod}.pm"),
    );
    $line = read_file_string($pm_pred);
    like($line, qr/http:\/\/a\.galaxy\.far\.far\.away\/modules/s,
        "Omission of WEBSITE from constructor args inserts dummy copy into documentation");

    note("    24b:  WEBSITE set to Perl-false value; no website printed");
    $testmod = 'Zeta';
    @components = ( 'Alpha', $testmod );
    $module_name = join('::' => @components);
    $dist_name = join('-' => @components);
    $path_str = File::Spec->catdir(@components);

    %these_args = (
        NAME           => $module_name,
        %sample_args,
    );
    $these_args{WEBSITE} = '';

    my $mod2 = ExtUtils::ModuleMaker->new(%these_args);
    ok($mod2, "call ExtUtils::ModuleMaker->new for $dist_name");

    ok( $mod2->complete_build(), 'call complete_build()' );

    ($module_file, $test_file) = compact_build_tests(\@components);

    $pm_pred = (
        File::Spec->catfile($dist_name, 'lib', 'Alpha', "${testmod}.pm"),
    );
    $line = read_file_string($pm_pred);
    unlike($line, qr/http:\/\/a\.galaxy\.far\.far\.away\/modules/s,
        "Assignment of Perl-false value to WEBSITE in constructor prevents insertion of dummy copy into documentation");

    note("    24c:  CPANID, WEBSITE and ORGANIZATION all set to Perl-false value");
    $testmod = 'Eta';
    @components = ( 'Alpha', $testmod );
    $module_name = join('::' => @components);
    $dist_name = join('-' => @components);
    $path_str = File::Spec->catdir(@components);

    %these_args = (
        NAME           => $module_name,
        %sample_args,
    );
    @these_args{qw| CPANID WEBSITE ORGANIZATION|} = ('') x 3;

    my $mod3 = ExtUtils::ModuleMaker->new(%these_args);
    ok($mod3, "call ExtUtils::ModuleMaker->new for $dist_name");

    ok( $mod3->complete_build(), 'call complete_build()' );

    ($module_file, $test_file) = compact_build_tests(\@components);

    my @lines;
    ok(@lines = read_file_array($module_file),
        'Able to read module into array');
    my $author_index;
    for (my $i=0;$i<=$#lines;$i++) {
        if ($lines[$i] =~ m/^=head1 AUTHOR/) {
            $author_index = $i;
            last;
        }
    }
    my $AUTHOR_section = join("\n" => @lines[$author_index .. ($author_index +4)]);
    unlike($AUTHOR_section, qr/MODAUTHOR/,
        "Assignment of Perl-false value to CPANID in constructor prevents insertion of dummy copy into documentation");
    unlike($AUTHOR_section, qr/http:\/\/a\.galaxy\.far\.far\.away\/modules/s,
        "Assignment of Perl-false value to WEBSITE in constructor prevents insertion of dummy copy into documentation");
    unlike($AUTHOR_section, qr/XYZ Corp\./,
        "Assignment of Perl-false value to ORGANIZATION in constructor prevents insertion of dummy copy into documentation");

    ok(chdir $cwd, "Able to change back to starting directory");
}

done_testing();

################### SUBROUTINES ###################


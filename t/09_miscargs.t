# t/09_miscargs.t
# tests of miscellaneous arguments passed to constructor
use strict;
local $^W = 1;
use Test::More 
# tests =>  431;
qw(no_plan);
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'Cwd');
use_ok( 'ExtUtils::ModuleMaker::Utility', qw( 
        _preexists_mmkr_directory
        _make_mmkr_directory
        _restore_mmkr_dir_status
    )
);
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
        _process_personal_defaults_file 
        _reprocess_personal_defaults_file 
        read_file_string
        read_file_array
    )
);


SKIP: {
    eval { require 5.006_001 };
    skip "tests require File::Temp, core with 5.6", 
        (431 - 4) if $@;
    use warnings;
    use_ok( 'File::Temp', qw| tempdir |);
    use ExtUtils::ModuleMaker::Auxiliary qw(
        read_file_string
        read_file_array
    );
    use lib('t/testlib');
    use_ok( 'IO::Capture::Stdout' );

    my $odir = cwd();
    my ($tdir, $mod, $testmod, $filetext, @filelines, %lines);

    ########################################################################
    # Sets 1 and 2:  Test VERBOSE => 1 to make sure that logging messages
    # note each directory and file created. 1:  Compact top directory.
    # 2:  Non-compact top directory.

    {   # Set 1
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        $testmod = 'Beta';
        
        ok( $mod = ExtUtils::ModuleMaker->new( 
                NAME           => "Alpha::$testmod",
                COMPACT        => 1,
                VERBOSE        => 1,
            ),
            "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
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

        ok( -d qq{Alpha-$testmod}, "compact top-level directory exists" );
        ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );
        ok( -d, "directory $_ exists" ) for ( qw/lib scripts t/);
        ok( -f, "file $_ exists" )
            for ( qw/Changes LICENSE Makefile.PL MANIFEST README Todo/);
        ok( -f, "file $_ exists" )
            for ( "lib/Alpha/${testmod}.pm", "t/001_load.t" );
        
        ok($filetext = read_file_string('Makefile.PL'),
            'Able to read Makefile.PL');
        
        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $odir, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");

    }
     
    {   # Set 2
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        $testmod = 'Gamma';
        
        ok( $mod = ExtUtils::ModuleMaker->new( 
                NAME           => "Alpha::$testmod",
                COMPACT        => 0,
                VERBOSE        => 1,
            ),
            "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
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

        ok( -d qq{Alpha/$testmod}, "non-compact top-level directories exist" );
        ok( chdir "Alpha/$testmod", "cd Alpha/$testmod" );
        ok( -d, "directory $_ exists" ) for ( qw/lib lib\/Alpha scripts t/);
        ok( -f, "file $_ exists" )
            for ( qw/Changes LICENSE Makefile.PL MANIFEST README Todo/);
        ok( -f, "file $_ exists" )
            for ( "lib/Alpha/${testmod}.pm", "t/001_load.t" );
        
        ok($filetext = read_file_string('Makefile.PL'),
            'Able to read Makefile.PL');
        
        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $odir, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");

    }

    ##### Sets 3 and 4:  Tests of dump_keys() and dump_keys_except() methods.
    {
        $tdir = tempdir( CLEANUP => 1);

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        ok(chdir $tdir, 'changed to temp directory for testing');
        $testmod = 'Tau';
        
        ok( $mod = ExtUtils::ModuleMaker->new( 
                NAME           => "Alpha::$testmod",
                COMPACT        => 0,
                VERBOSE        => 1,
                ABSTRACT       => "Tau's the time for Perl",
            ),
            "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
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
        
        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $odir, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");

    }

    {
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        $testmod = 'Rho';
        
        ok( $mod = ExtUtils::ModuleMaker->new( 
                NAME           => "Alpha::$testmod",
                COMPACT        => 0,
                VERBOSE        => 1,
            ),
            "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
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
        
        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $odir, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");

    }

    ##### Sets 5 & 6 & 7:  Tests of NEED_POD and NEED_NEW_METHOD options #####

    {
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        $testmod = 'Phi';
        
        ok( $mod = ExtUtils::ModuleMaker->new( 
                NAME           => "Alpha::$testmod",
                COMPACT        => 1,
                NEED_POD       => 0,
            ),
            "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
        );
        
        ok( $mod->complete_build(), 'call complete_build()' );

        ok( -d qq{Alpha-$testmod}, "compact top-level directory exists" );
        ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );
        ok( -d, "directory $_ exists" ) for ( qw/lib scripts t/);
        ok( -f, "file $_ exists" )
            for ( qw/Changes LICENSE Makefile.PL MANIFEST README Todo/);
        ok( -f, "file $_ exists" )
            for ( "lib/Alpha/${testmod}.pm", "t/001_load.t" );
        
        ok($filetext = read_file_string('Makefile.PL'),
            'Able to read Makefile.PL');
        ok(@filelines = read_file_array("lib/Alpha/${testmod}.pm"),
            'Able to read module into array');
        is( (grep {/^=(head|cut)/} @filelines), 0, 
            "no POD correctly detected in module");

        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $odir, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");

    }
        
    {
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        $testmod = 'Chi';
        
        ok( $mod = ExtUtils::ModuleMaker->new( 
                NAME            => "Alpha::$testmod",
                COMPACT         => 1,
                NEED_NEW_METHOD => 0,
            ),
            "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
        );
        
        ok( $mod->complete_build(), 'call complete_build()' );

        ok( -d qq{Alpha-$testmod}, "compact top-level directory exists" );
        ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );
        ok( -d, "directory $_ exists" ) for ( qw/lib scripts t/);
        ok( -f, "file $_ exists" )
            for ( qw/Changes LICENSE Makefile.PL MANIFEST README Todo/);
        ok( -f, "file $_ exists" )
            for ( "lib/Alpha/${testmod}.pm", "t/001_load.t" );
        
        ok($filetext = read_file_string('Makefile.PL'),
            'Able to read Makefile.PL');
        ok(@filelines = read_file_array("lib/Alpha/${testmod}.pm"),
            'Able to read module into array');
        is( (grep {/^sub new/} @filelines), 0, 
            "no sub new() correctly detected in module");

        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $odir, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");

    }
        
    {
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        $testmod = 'Xi';
        
        ok( $mod = ExtUtils::ModuleMaker->new( 
                NAME            => "Alpha::$testmod",
                COMPACT         => 1,
                NEED_POD        => 0,
                NEED_NEW_METHOD => 0,
            ),
            "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
        );
        
        ok( $mod->complete_build(), 'call complete_build()' );

        ok( -d qq{Alpha-$testmod}, "compact top-level directory exists" );
        ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );
        ok( -d, "directory $_ exists" ) for ( qw/lib scripts t/);
        ok( -f, "file $_ exists" )
            for ( qw/Changes LICENSE Makefile.PL MANIFEST README Todo/);
        ok( -f, "file $_ exists" )
            for ( "lib/Alpha/${testmod}.pm", "t/001_load.t" );
        
        ok($filetext = read_file_string('Makefile.PL'),
            'Able to read Makefile.PL');
        ok(@filelines = read_file_array("lib/Alpha/${testmod}.pm"),
            'Able to read module into array');
        is( (grep {/^(sub new|=(head|cut))/} @filelines), 0, 
            "no sub new() or POD correctly detected in module");

        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $odir, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");

    }
        
    ######### Set #8:  Test of EXTRA_MODULES Option ##########
     
    {
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        $testmod = 'Sigma';
        
        ok( $mod = ExtUtils::ModuleMaker->new( 
                NAME           => "Alpha::$testmod",
                COMPACT        => 1,
                EXTRA_MODULES  => [
                    { NAME => "Alpha::${testmod}::Gamma" },
                    { NAME => "Alpha::${testmod}::Delta" },
                    { NAME => "Alpha::${testmod}::Gamma::Epsilon" },
                ],
            ),
            "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
        );
        
        ok( $mod->complete_build(), 'call complete_build()' );

        ok( -d qq{Alpha-$testmod}, "compact top-level directory exists" );
        ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );
        ok( -d, "directory $_ exists" ) for ( qw/lib scripts t/);
        ok( -f, "file $_ exists" )
            for ( qw/Changes LICENSE Makefile.PL MANIFEST README Todo/);
        ok( -d, "directory $_ exists" ) for (
                "lib/Alpha",
                "lib/Alpha/${testmod}",
                "lib/Alpha/${testmod}/Gamma",
            );
        ok( -f, "file $_ exists" )
            for (
                "lib/Alpha/${testmod}.pm",
                "lib/Alpha/${testmod}/Gamma.pm",
                "lib/Alpha/${testmod}/Delta.pm",
                "lib/Alpha/${testmod}/Gamma/Epsilon.pm",
                't/001_load.t',
                't/002_load.t',
                't/003_load.t',
                't/004_load.t',
            );
        
        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $odir, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");

    }

    ########################################################################
    # Set 9:  Test VERSION for value other than 0.01; make sure it is quoted
    # in .pm file.

    {
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        $testmod = 'Beta';
        
        ok( $mod = ExtUtils::ModuleMaker->new( 
                NAME           => "Alpha::$testmod",
                COMPACT        => 1,
                VERSION        => q{0.3},
            ),
            "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
        );
        
        ok( $mod->complete_build(), 'call complete_build()' );

        ok( -d qq{Alpha-$testmod}, "compact top-level directory exists" );
        ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );
        ok( -d, "directory $_ exists" ) for ( qw/lib scripts t/);
        ok( -f, "file $_ exists" )
            for ( qw/Changes LICENSE Makefile.PL MANIFEST README Todo/);
        ok( -f, "file $_ exists" )
            for ( "lib/Alpha/${testmod}.pm", "t/001_load.t" );
        
        ok($filetext = read_file_string("lib/Alpha/$testmod.pm"),
            "Able to read lib/Alpha/$testmod.pm");
        like($filetext, qr/\$VERSION\s+=\s+'0\.3'/,
            "VERSION number is correct and properly quoted");
        
        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $odir, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");

    }
     
    ######### Set # 10:  Test of EXTRA_MODULES Option ##########
    ########## with all tests in a single file #################
     
    {
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        $testmod = 'Sigma';
        
        ok( $mod = ExtUtils::ModuleMaker->new( 
                NAME           => "Alpha::$testmod",
                COMPACT        => 1,
                EXTRA_MODULES  => [
                    { NAME => "Alpha::${testmod}::Gamma" },
                    { NAME => "Alpha::${testmod}::Delta" },
                    { NAME => "Alpha::${testmod}::Gamma::Epsilon" },
                ],
                EXTRA_MODULES_SINGLE_TEST_FILE => 1,
            ),
            "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
        );
        
        ok( $mod->complete_build(), 'call complete_build()' );

        ok( -d qq{Alpha-$testmod}, "compact top-level directory exists" );
        ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );
        ok( -d, "directory $_ exists" ) for ( qw/lib scripts t/);
        ok( -f, "file $_ exists" )
            for ( qw/Changes LICENSE Makefile.PL MANIFEST README Todo/);
        ok( -d, "directory $_ exists" ) for (
                "lib/Alpha",
                "lib/Alpha/${testmod}",
                "lib/Alpha/${testmod}/Gamma",
            );
        ok( -f, "file $_ exists" )
            for (
                "lib/Alpha/${testmod}.pm",
                "lib/Alpha/${testmod}/Gamma.pm",
                "lib/Alpha/${testmod}/Delta.pm",
                "lib/Alpha/${testmod}/Gamma/Epsilon.pm",
                't/001_load.t',
            );
        
        my $filetext = read_file_string("t/001_load.t");
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

        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $odir, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");

    }

    ######### Set # 11:  Test of EXTRA_MODULES Option ##########
    ########## with test names derived from module names #######
     
    {
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        $testmod = 'Sigma';
        
        ok( $mod = ExtUtils::ModuleMaker->new( 
                NAME           => "Alpha::$testmod",
                COMPACT        => 1,
                EXTRA_MODULES  => [
                    { NAME => "Alpha::${testmod}::Gamma" },
                    { NAME => "Alpha::${testmod}::Delta" },
                    { NAME => "Alpha::${testmod}::Gamma::Epsilon" },
                ],
                TEST_NAME_DERIVED_FROM_MODULE_NAME => 1,
                TEST_NUMBER_FORMAT  => undef,
            ),
            "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
        );
        
        ok( $mod->complete_build(), 'call complete_build()' );

        ok( -d qq{Alpha-$testmod}, "compact top-level directory exists" );
        ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );
        ok( -d, "directory $_ exists" ) for ( qw/lib scripts t/);
        ok( -f, "file $_ exists" )
            for ( qw/Changes LICENSE Makefile.PL MANIFEST README Todo/);
        ok( -d, "directory $_ exists" ) for (
                "lib/Alpha",
                "lib/Alpha/${testmod}",
                "lib/Alpha/${testmod}/Gamma",
        );
        ok( -f, "file $_ exists" )
            for (
                "lib/Alpha/${testmod}.pm",
                "lib/Alpha/${testmod}/Gamma.pm",
                "lib/Alpha/${testmod}/Delta.pm",
                "lib/Alpha/${testmod}/Gamma/Epsilon.pm",
                "t/Alpha_${testmod}.t",
                "t/Alpha_${testmod}_Gamma.t",
                "t/Alpha_${testmod}_Delta.t",
                "t/Alpha_${testmod}_Gamma_Epsilon.t",
        );
        
        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $odir, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");

    }

    ######### Set # 12:  Test of EXTRA_MODULES Option ##########
    ########## with all tests in a single file #################
    ########## with no number in test name #####################
     
    {
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        $testmod = 'Sigma';
        
        ok( $mod = ExtUtils::ModuleMaker->new( 
                NAME           => "Alpha::$testmod",
                COMPACT        => 1,
                EXTRA_MODULES  => [
                    { NAME => "Alpha::${testmod}::Gamma" },
                    { NAME => "Alpha::${testmod}::Delta" },
                    { NAME => "Alpha::${testmod}::Gamma::Epsilon" },
                ],
                EXTRA_MODULES_SINGLE_TEST_FILE => 1,
                TEST_NUMBER_FORMAT  => undef,
            ),
            "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
        );
        
        ok( $mod->complete_build(), 'call complete_build()' );

        ok( -d qq{Alpha-$testmod}, "compact top-level directory exists" );
        ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );
        ok( -d, "directory $_ exists" ) for ( qw/lib scripts t/);
        ok( -f, "file $_ exists" )
            for ( qw/Changes LICENSE Makefile.PL MANIFEST README Todo/);
        ok( -d, "directory $_ exists" ) for (
                "lib/Alpha",
                "lib/Alpha/${testmod}",
                "lib/Alpha/${testmod}/Gamma",
        );
        ok( -f, "file $_ exists" )
            for (
                "lib/Alpha/${testmod}.pm",
                "lib/Alpha/${testmod}/Gamma.pm",
                "lib/Alpha/${testmod}/Delta.pm",
                "lib/Alpha/${testmod}/Gamma/Epsilon.pm",
                "t/load.t",
        );
        
        my $filetext = read_file_string("t/load.t");
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

        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $odir, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");

    }

    ##### Set 13:  Test of INCLUDE_MANIFEST_SKIP option #####

    {
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        $testmod = 'Phi';
        
        ok( $mod = ExtUtils::ModuleMaker->new( 
                NAME           => "Alpha::$testmod",
                COMPACT        => 1,
                INCLUDE_MANIFEST_SKIP => 1,
            ),
            "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
        );
        
        ok( $mod->complete_build(), 'call complete_build()' );

        ok( -d qq{Alpha-$testmod}, "compact top-level directory exists" );
        ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );
        ok( -d, "directory $_ exists" ) for ( qw/lib scripts t/);
        ok( -f, "file $_ exists" )
            for ( qw|
                Changes     LICENSE Makefile.PL 
                MANIFEST    README  Todo        MANIFEST.SKIP
            | );
        ok( -f, "file $_ exists" )
            for ( "lib/Alpha/${testmod}.pm", "t/001_load.t" );
        
        ok($filetext = read_file_string('Makefile.PL'),
            'Able to read Makefile.PL');

        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $odir, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");
    }
        
    ##### Set 14:  Test of (negating) INCLUDE_TODO option #####

    {
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        $testmod = 'Phi';
        
        ok( $mod = ExtUtils::ModuleMaker->new( 
                NAME           => "Alpha::$testmod",
                COMPACT        => 1,
                INCLUDE_TODO   => 0,
            ),
            "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
        );
        
        ok( $mod->complete_build(), 'call complete_build()' );

        ok( -d qq{Alpha-$testmod}, "compact top-level directory exists" );
        ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );
        ok( -d, "directory $_ exists" ) for ( qw/lib scripts t/);
        ok( -f, "file $_ exists" )
            for ( qw|
                Changes     LICENSE      Makefile.PL 
                MANIFEST    README
            | );
        ok(! -f 'Todo', "Todo correctly not created" );
        ok( -f, "file $_ exists" )
            for ( "lib/Alpha/${testmod}.pm", "t/001_load.t" );
        
        ok($filetext = read_file_string('Makefile.PL'),
            'Able to read Makefile.PL');

        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $odir, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");
    }
        
    ##### Set 15:  Test of INCLUDE_POD_COVERAGE_TEST ###############
    ################## and INCLUDE_POD_TEST options ################

    {
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        $testmod = 'Phi';
        
        ok( $mod = ExtUtils::ModuleMaker->new( 
                NAME                        => "Alpha::$testmod",
                COMPACT                     => 1,
                INCLUDE_POD_COVERAGE_TEST   => 1,
                INCLUDE_POD_TEST            => 1,
            ),
            "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
        );
        
        ok( $mod->complete_build(), 'call complete_build()' );

        ok( -d qq{Alpha-$testmod}, "compact top-level directory exists" );
        ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );
        ok( -d, "directory $_ exists" ) for ( qw/lib scripts t/);
        ok( -f, "file $_ exists" )
            for ( qw|
                Changes     LICENSE     Makefile.PL 
                MANIFEST    README      Todo
            | );
        ok( -f, "file $_ exists" )
            for ( "lib/Alpha/${testmod}.pm", "t/001_load.t",
                    "t/pod-coverage.t", "t/pod.t" );
        
        ok($filetext = read_file_string('Makefile.PL'),
            'Able to read Makefile.PL');

        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $odir, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");
    }
        
    ##### Set 16:  Test of (negation of) INCLUDE_LICENSE option #####

    {
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        $testmod = 'Xi';
        
        ok( $mod = ExtUtils::ModuleMaker->new( 
                NAME                        => "Alpha::$testmod",
                COMPACT                     => 1,
                INCLUDE_LICENSE             => 0,
            ),
            "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
        );
        
        ok( $mod->complete_build(), 'call complete_build()' );

        ok( -d qq{Alpha-$testmod}, "compact top-level directory exists" );
        ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );
        ok( -d, "directory $_ exists" ) for ( qw/lib scripts t/);
        ok( -f, "file $_ exists" )
            for ( qw|
                Changes                 Makefile.PL 
                MANIFEST    README      Todo
            | );
        ok( -f, "file $_ exists" )
            for ( "lib/Alpha/${testmod}.pm", "t/001_load.t" );
        ok(! -f 'LICENSE', "LICENSE correctly not created" );
        
        ok($filetext = read_file_string('Makefile.PL'),
            'Able to read Makefile.PL');

        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $odir, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");
    }
        
    ##### Set 17:  Test of (negating) INCLUDE_SCRIPTS_DIRECTORY option #####

    {
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        $testmod = 'Phi';
        
        ok( $mod = ExtUtils::ModuleMaker->new( 
                NAME           => "Alpha::$testmod",
                COMPACT        => 1,
                INCLUDE_SCRIPTS_DIRECTORY => 0,
            ),
            "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
        );
        
        ok( $mod->complete_build(), 'call complete_build()' );

        ok( -d qq{Alpha-$testmod}, "compact top-level directory exists" );
        ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );
        ok( -d, "directory $_ exists" ) for ( qw/lib         t/);
        ok(! -d 'scripts', "scripts directory correctly not created");

        ok( -f, "file $_ exists" )
            for ( qw|
                Changes     LICENSE      Makefile.PL 
                MANIFEST    README       Todo
            | );
        ok( -f, "file $_ exists" )
            for ( "lib/Alpha/${testmod}.pm", "t/001_load.t" );
        
        ok($filetext = read_file_string('Makefile.PL'),
            'Able to read Makefile.PL');

        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $odir, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");
    }
        
    ##### Set 18:  Test of INCLUDE_FILE_IN_PM option #####

    {
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        $testmod = 'Kappa';
        
        ok( $mod = ExtUtils::ModuleMaker->new( 
                NAME           => "Alpha::$testmod",
                COMPACT        => 1,
                EXTRA_MODULES  => [
                    { NAME => "Alpha::${testmod}::Gamma" },
                    { NAME => "Alpha::${testmod}::Delta" },
                    { NAME => "Alpha::${testmod}::Gamma::Epsilon" },
                ],
                INCLUDE_FILE_IN_PM => "$odir/t/testlib/arbitrary.txt",
            ),
            "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
        );
        
        ok( $mod->complete_build(), 'call complete_build()' );

        ok( -d qq{Alpha-$testmod}, "compact top-level directory exists" );
        ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );
        ok( -d, "directory $_ exists" ) for ( qw/lib scripts t/);

        ok( -f, "file $_ exists" )
            for ( qw|
                Changes     LICENSE      Makefile.PL 
                MANIFEST    README       Todo
            | );

        ok( -d, "directory $_ exists" ) for (
                "lib/Alpha",
                "lib/Alpha/${testmod}",
                "lib/Alpha/${testmod}/Gamma",
            );

        my @pm_pred = (
                "lib/Alpha/${testmod}.pm",
                "lib/Alpha/${testmod}/Gamma.pm",
                "lib/Alpha/${testmod}/Delta.pm",
                "lib/Alpha/${testmod}/Gamma/Epsilon.pm",
        );
        my @t_pred = (
                't/001_load.t',
                't/002_load.t',
                't/003_load.t',
                't/004_load.t',
        );
        ok( -f, "file $_ exists" ) for ( @pm_pred, @t_pred);
        for my $pm (@pm_pred) {
            my $line = read_file_string($pm);
            like($line, qr<=pod.+INCLUDE_FILE_IN_PM.+sub marine {}>s,
                "$pm contains pod header, key-value pair, sub");
        }

        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $odir, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");
    }
        
} # end SKIP block


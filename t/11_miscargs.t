# t/11_miscargs.t
# tests of miscellaneous arguments passed to constructor
use strict;
local $^W = 1;
use Test::More 
tests =>  141;
# qw(no_plan);
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'Cwd');


SKIP: {
    eval { require 5.006_001 };
    skip "tests require File::Temp, core with 5.6", 
        (141 - 2) if $@;
    use warnings;
    use_ok( 'File::Temp', qw| tempdir |);
    use lib ("./t/testlib");
    use _Auxiliary qw(
        read_file_string
        read_file_array
    );
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
        
        ok(chdir $odir, 'changed back to original directory after testing');
    }
     
    {   # Set 2
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');
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
        
        ok(chdir $odir, 'changed back to original directory after testing');
    }

    ##### Sets 3 and 3a:  Tests of dump_keys() and dump_keys_except() methods.
    {
        $tdir = tempdir( CLEANUP => 1);
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
        
        ok(chdir $odir, 'changed back to original directory after testing');
    }

    {
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');
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
        
        ok(chdir $odir, 'changed back to original directory after testing');
    }

    ##### Sets 4 & 5 & 6:  Tests of NEED_POD and NEED_NEW_METHOD options #####

    {
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');
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

        ok(chdir $odir, 'changed back to original directory after testing');
    }
        
    {
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');
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

        ok(chdir $odir, 'changed back to original directory after testing');
    }
        
    {
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');
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
            "no sub new() correctly detected in module");

        ok(chdir $odir, 'changed back to original directory after testing');
    }
        
    ######### Set #7:  Test of EXTRA_MODULES Option ##########
     
    {
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');
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
        
        ok(chdir $odir, 'changed back to original directory after testing');
    }

} # end SKIP block


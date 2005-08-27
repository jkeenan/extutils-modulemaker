# t/18_make_selections_defaults.t
use strict;
local $^W = 1;
use Test::More 
# tests => 130;
qw(no_plan);
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'Cwd');
use_ok( 'ExtUtils::ModuleMaker::Utility', qw( 
        _get_personal_defaults_directory
    )
);
use lib ("./t/testlib");
use_ok( 'Auxiliary', qw(
        _process_personal_defaults_file 
        _reprocess_personal_defaults_file 
    )
);

SKIP: {
    eval { require 5.006_001 };
    skip "tests require File::Temp, core with 5.6", 
        (87 - 6) if $@;
    use warnings;
    use_ok( 'File::Temp', qw| tempdir |);
    use lib ("./t/testlib");
    use Auxiliary qw(
        check_MakefilePL 
        check_pm_file
        make_compact
    );

    my $cwd = cwd();
    my ($tdir, $topdir, @pred, $module_name, $pmfile, %pred);

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

    {
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $personal_dir = _get_personal_defaults_directory();
        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $personal_dir, $pers_file );

        push @INC, "$cwd/t/testlib";
        require ExtUtils::ModuleMaker::Testing::Defaults;
        my $testing_defaults_ref =
            ExtUtils::ModuleMaker::Testing::Defaults->default_values();
        my $obj1 = ExtUtils::ModuleMaker->new( %{$testing_defaults_ref} );
        isa_ok( $obj1, 'ExtUtils::ModuleMaker' );

        ok( $obj1->complete_build(), 'call complete_build()' );

        $topdir = "EU/MM/Testing/Defaults"; 
        ok(-d $topdir, "by default, non-compact top directory created");
        ok(-f "$topdir/$_", "$_ file created")
            for qw| Changes LICENSE MANIFEST Makefile.PL README Todo |;
        ok(-d "$topdir/$_", "$_ directory created")
            for qw| lib t |;
        
        @pred = (
             q{EU::MM::Testing::Defaults},
            qq{lib\/EU\/MM\/Testing\/Defaults\.pm},
            qq{Hilton\\sStallone},
            qq{hiltons\@parliamentarypictures\.com},
            qq{Module\\sabstract\\s\\(<=\\s44\\scharacters\\)\\sgoes\\shere},
        );

        check_MakefilePL($topdir, \@pred);

        $obj1->make_selections_defaults();
        ok(-f "$personal_dir/$pers_file", "new Personal::Defaults installed");

        my $obj2 = ExtUtils::ModuleMaker->new(
            NAME    => q{Ackus::Frackus},
            AUTHOR  => q{Marilyn Shmarilyn},
            EMAIL   => q{marilyns@nineteenthcenturyfox.com},
            COMPACT => 1,
        );
        isa_ok( $obj2, 'ExtUtils::ModuleMaker' );

        ok( $obj2->complete_build(), 'call complete_build()' );

        $topdir = "Ackus-Frackus"; 
        ok(-d $topdir, "by choice, compact top directory created");
        ok(-f "$topdir/$_", "$_ file created")
            for qw| Changes LICENSE MANIFEST Makefile.PL README Todo |;
        ok(-d "$topdir/$_", "$_ directory created")
            for qw| lib t |;
        
        @pred = (
             q{Ackus::Frackus},
            qq{lib\/Ackus\/Frackus\.pm},
            qq{Marilyn\\sShmarilyn},
            qq{marilyns\@nineteenthcenturyfox\.com},
            qq{Module\\sabstract\\s\\(<=\\s44\\scharacters\\)\\sgoes\\shere},
        );

        check_MakefilePL($topdir, \@pred);

        _reprocess_personal_defaults_file( $pers_def_ref );

        ok(chdir $cwd, 'changed back to original directory after testing');
    }

    {
        # same test as above, only using modulemaker utility in
        # non-interactive mode to set Testing::Defaults as temporary
        # Personal::Defaults
        # PROBLEM:  This will not work because setting the -t option for
        # Testing::Defaults supersedes all other arguments to modulemaker

#        $tdir = tempdir( CLEANUP => 1);
#        ok(chdir $tdir, 'changed to temp directory for testing');
#
#        my $personal_dir = _get_personal_defaults_directory();
#        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
#        my $pers_def_ref = 
#            _process_personal_defaults_file( $personal_dir, $pers_file );
#
##        my $obj1 = ExtUtils::ModuleMaker->new(
##           TESTING_DEFAULTS_FILE =>  
##                "$cwd/t/testlib/ExtUtils/ModuleMaker/Testing/Defaults.pm",
##        );
##        isa_ok( $obj1, 'ExtUtils::ModuleMaker' );
##
##        ok( $obj1->complete_build(), 'call complete_build()' );
#
#        ok(! system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/modulemaker" -t "$cwd/t/testlib/ExtUtils/ModuleMaker/Testing/Defaults.pm" }), 
#            "able to call modulemaker utility");
#
#        $topdir = "EU/MM/Testing/Defaults"; 
#        $topdir = "EU/MM/Testing/Defaults"; 
#        ok(-d $topdir, "by default, non-compact top directory created");
#        ok(-f "$topdir/$_", "$_ file created")
#            for qw| Changes LICENSE MANIFEST Makefile.PL README Todo |;
#        ok(-d "$topdir/$_", "$_ directory created")
#            for qw| lib t |;
#        
#        @pred = (
#             q{EU::MM::Testing::Defaults},
#            qq{lib\/EU\/MM\/Testing\/Defaults\.pm},
#            qq{Hilton\\sStallone},
#            qq{hiltons\@parliamentarypictures\.com},
#            qq{Module\\sabstract\\s\\(<=\\s44\\scharacters\\)\\sgoes\\shere},
#        );
#
#        check_MakefilePL($topdir, \@pred);
#
#        $obj1->make_selections_defaults();
#        ok(-f "$personal_dir/$pers_file", "new Personal::Defaults installed");
#
#        my $obj2 = ExtUtils::ModuleMaker->new(
#            NAME    => q{Ackus::Frackus},
#            AUTHOR  => q{Marilyn Shmarilyn},
#            EMAIL   => q{marilyns@nineteenthcenturyfox.com},
#            COMPACT => 1,
#        );
#        isa_ok( $obj2, 'ExtUtils::ModuleMaker' );
#
#        ok( $obj2->complete_build(), 'call complete_build()' );
#
#        $topdir = "Ackus-Frackus"; 
#        ok(-d $topdir, "by choice, compact top directory created");
#        ok(-f "$topdir/$_", "$_ file created")
#            for qw| Changes LICENSE MANIFEST Makefile.PL README Todo |;
#        ok(-d "$topdir/$_", "$_ directory created")
#            for qw| lib t |;
#        
#        @pred = (
#             q{Ackus::Frackus},
#            qq{lib\/Ackus\/Frackus\.pm},
#            qq{Marilyn\\sShmarilyn},
#            qq{marilyns\@nineteenthcenturyfox\.com},
#            qq{Module\\sabstract\\s\\(<=\\s44\\scharacters\\)\\sgoes\\shere},
#        );
#
#        check_MakefilePL($topdir, \@pred);
#
#        _reprocess_personal_defaults_file( $pers_def_ref );
#
#        ok(chdir $cwd, 'changed back to original directory after testing');
    }

} # end SKIP block


# t/15_personal_defaults.t
use strict;
use Test::More tests => 54;

BEGIN { use_ok('ExtUtils::ModuleMaker'); }
BEGIN { use_ok('Cwd'); }

SKIP: {
    eval { require 5.006_001 };
    skip "tests require File::Temp, core with 5.6", 52 if $@;
    use warnings;
    use_ok( 'File::Temp', qw| tempdir |);
    use lib ("./t/testlib");
    use _Auxiliary qw(
        check_MakefilePL 
        check_pm_file
        make_compact
    );

    # PERSONAL_DEFAULTS override the standard defaults but in turn are
    # overriden by arguments supplied to constructor or as options to
    # modulemaker.

    my $cwd = cwd();
    my ($tdir, $mod, $topdir, @pred, $module_name, $pmfile, %pred);


    {
        # provide name and call for compact top-level directory but supply a
        # bad value for personal defaults file

        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        eval { $mod = ExtUtils::ModuleMaker->new( 
            NAME              => 'XYZ-ABC',
            COMPACT           => 1,
            PERSONAL_DEFAULTS => "$cwd/t/testlib/01.sample.modulemakerrc.fake",
        ); };
        like($@, qr/^No\spersonal\sdefaults\sfile/,
            "absence of personal defaults file correctly detected");

        ok(chdir $cwd, 'changed back to original directory after testing');
    }

    {
        # provide name and call for compact top-level directory

        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        $mod = ExtUtils::ModuleMaker->new( 
            NAME              => 'XYZ::ABC',
            COMPACT           => 1,
            PERSONAL_DEFAULTS => "$cwd/t/testlib/01.sample.modulemakerrc",
        );
        $mod->complete_build();

        $topdir = "XYZ-ABC"; 
        ok(-d $topdir, "compact top directory created");
        ok(-f "$topdir/$_", "$_ file created")
            for qw| Changes LICENSE MANIFEST Makefile.PL README Todo |;
        ok(-d "$topdir/$_", "$_ directory created")
            for qw| lib t |;
        
        @pred = (
            "XYZ::ABC",
            "lib\/XYZ\/ABC\.pm",
            "Just\\sAnother\\sPerl\\sHacker",
            "japh\@a\.galaxy\.far\.far\.away",
            "Module\\sabstract\\s\\(<=\\s44\\scharacters\\)\\sgoes\\shere",
        );
        check_MakefilePL($topdir, \@pred);
        ok(chdir $cwd, 'changed back to original directory after testing');
    }

    {
        # provide name and call for compact top-level directory
        # add in abstract
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        $mod = ExtUtils::ModuleMaker->new( 
            NAME              => 'XYZ::ABC',
            ABSTRACT          => "This is very abstract.",
            COMPACT           => 1,
            PERSONAL_DEFAULTS => "$cwd/t/testlib/01.sample.modulemakerrc",
        );
        $mod->complete_build();

        $topdir = "XYZ-ABC"; 
        ok(-d $topdir, "compact top directory created");
        ok(-f "$topdir/$_", "$_ file created")
            for qw| Changes LICENSE MANIFEST Makefile.PL README Todo |;
        ok(-d "$topdir/$_", "$_ directory created")
            for qw| lib t |;
        
        @pred = (
            "XYZ::ABC",
            "lib\/XYZ\/ABC\.pm",
            "Just\\sAnother\\sPerl\\sHacker",
            "japh\@a\.galaxy\.far\.far\.away",
            "This\\sis\\svery\\sabstract\.",
        );
        check_MakefilePL($topdir, \@pred);
        ok(chdir $cwd, 'changed back to original directory after testing');
    }

    {
        # provide name and call for compact top-level directory
        # add in abstract and author-name
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        $mod = ExtUtils::ModuleMaker->new( 
            NAME              => 'XYZ::ABC',
            ABSTRACT          => "This is very abstract.",
            AUTHOR            => "John Q Public",
            COMPACT           => 1,
            PERSONAL_DEFAULTS => "$cwd/t/testlib/01.sample.modulemakerrc",
        );
        $mod->complete_build();

        $topdir = "XYZ-ABC"; 
        ok(-d $topdir, "compact top directory created");
        ok(-f "$topdir/$_", "$_ file created")
            for qw| Changes LICENSE MANIFEST Makefile.PL README Todo |;
        ok(-d "$topdir/$_", "$_ directory created")
            for qw| lib t |;
        
        @pred = (
            "XYZ::ABC",
            "lib\/XYZ\/ABC\.pm",
            "John\\sQ\\sPublic",
            "japh\@a\.galaxy\.far\.far\.away",
            "This\\sis\\svery\\sabstract\.",
        );
        check_MakefilePL($topdir, \@pred);
        ok(chdir $cwd, 'changed back to original directory after testing');
    }

    {
        # provide name and call for compact top-level directory
        # add in abstract and author-name and e-mail
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        $mod = ExtUtils::ModuleMaker->new( 
            NAME              => 'XYZ::ABC',
            ABSTRACT          => "This is very abstract.",
            AUTHOR            => "John Q Public",
            EMAIL             => 'jqpublic@calamity.jane.net',
            COMPACT           => 1,
            PERSONAL_DEFAULTS => "$cwd/t/testlib/01.sample.modulemakerrc",
        );
        $mod->complete_build();

        $topdir = "XYZ-ABC"; 
        ok(-d $topdir, "compact top directory created");
        ok(-f "$topdir/$_", "$_ file created")
            for qw| Changes LICENSE MANIFEST Makefile.PL README Todo |;
        ok(-d "$topdir/$_", "$_ directory created")
            for qw| lib t |;
        
        @pred = (
            "XYZ::ABC",
            "lib\/XYZ\/ABC\.pm",
            "John\\sQ\\sPublic",
            "jqpublic\@calamity\.jane\.net",
            "This\\sis\\svery\\sabstract\.",
        );
        check_MakefilePL($topdir, \@pred);
        ok(chdir $cwd, 'changed back to original directory after testing');
    }
} # end SKIP block


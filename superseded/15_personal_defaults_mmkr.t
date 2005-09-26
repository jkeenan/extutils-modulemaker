# t/16_personal_defaults_mmkr.t
use strict;
use Test::More tests => 88;

BEGIN { use_ok('ExtUtils::ModuleMaker'); }
BEGIN { use_ok('Cwd'); }

SKIP: {
    eval { require 5.006_001 };
    skip "tests require File::Temp, core with 5.6", 86 if $@;
    use warnings;
    use_ok( 'File::Temp', qw| tempdir |);
    use lib ("./t/testlib");
    use _Auxiliary qw(
        check_MakefilePL 
        check_pm_file
        make_compact
    );

    # Simple tests of modulemaker utility in non-interactive mode
    # using PERSONAL_DEFAULTS option 'd'
    # PERSONAL_DEFAULTS override the standard defaults but in turn are
    # overriden by arguments supplied to constructor or as options to
    # modulemaker.

    my $cwd = cwd();
    my ($tdir, $topdir, @pred, $module_name, $pmfile, %pred);

    {
        # provide name and call for compact top-level directory but supply a
        # bad value for personal defaults file

        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        ok(system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/modulemaker" -Icn XYZ::ABC -d "$cwd/t/testlib/01.sample.modulemakerrc.fake"}),
            "modulemaker correctly failed due to non-existent rc file");

        # I would like to test the error message EU::MM generates at this
        # point, but do not know how to do it from outside the system call.
        # Code below does not work; neither does IO::Capture::Stderr.
#        eval { ! system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/modulemaker" -Icn XYZ::ABC -d "$cwd/t/testlib/01.sample.modulemakerrc.fake"}); };
#print STDERR "ERROR:  ", $@, "XXX\n";
#        like($@, qr/^No\spersonal\sdefaults\sfile/,
#            "absence of personal defaults file correctly detected");

        ok(chdir $cwd, 'changed back to original directory after testing');
    }

    {
        # provide name and call for compact top-level directory

        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        ok(! system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/modulemaker" -Icn XYZ::ABC -d "$cwd/t/testlib/01.sample.modulemakerrc"}), 
            "able to call modulemaker utility");

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

        ok(! system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/modulemaker" -Icn XYZ::ABC -a \"This is very abstract.\" -d "$cwd/t/testlib/01.sample.modulemakerrc"}),
            "able to call modulemaker utility with abstract"); #"

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

        ok(! system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/modulemaker" -Icn XYZ::ABC -a \"This is very abstract.\" -u \"John Q Public\" -d "$cwd/t/testlib/01.sample.modulemakerrc"}),
            "able to call modulemaker utility with abstract"); #"

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

        ok(! system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/modulemaker" -Icn XYZ::ABC -a \"This is very abstract.\" -u \"John Q Public\" -e jqpublic\@calamity.jane.net -d "$cwd/t/testlib/01.sample.modulemakerrc"}),
            "able to call modulemaker utility with abstract"); #"

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

    {
        # provide name and call for compact top-level directory
        # call option to omit POD from .pm file
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        $module_name = 'XYZ::ABC';
        ok(! system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/modulemaker" -IcPn "$module_name"  -d "$cwd/t/testlib/01.sample.modulemakerrc"}),
            "able to call modulemaker utility");

        ($topdir, $pmfile) = make_compact($module_name); 
        ok(-d $topdir, "compact top directory created");
        ok(-f "$topdir/$_", "$_ file created")
            for qw| Changes LICENSE MANIFEST Makefile.PL README Todo |;
        ok(-d "$topdir/$_", "$_ directory created")
            for qw| lib t |;
        ok(-f $pmfile, "$pmfile created");
        
        %pred = (
            'pod_present'       => 0,
        );
        check_pm_file($pmfile, \%pred);

        ok(chdir $cwd, 'changed back to original directory after testing');
    }

    {
        # provide name and call for compact top-level directory
        # call option to omit constructor (sub new()) from .pm file
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        $module_name = 'XYZ::ABC';
        ok(! system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/modulemaker" -Icqn "$module_name"  -d "$cwd/t/testlib/01.sample.modulemakerrc"}),
            "able to call modulemaker utility");

        ($topdir, $pmfile) = make_compact($module_name); 
        ok(-d $topdir, "compact top directory created");
        ok(-f "$topdir/$_", "$_ file created")
            for qw| Changes LICENSE MANIFEST Makefile.PL README Todo |;
        ok(-d "$topdir/$_", "$_ directory created")
            for qw| lib t |;
        ok(-f $pmfile, "$pmfile created");
        
        %pred = (
            'constructor_present'       => 0,
        );
        check_pm_file($pmfile, \%pred);

        ok(chdir $cwd, 'changed back to original directory after testing');
    }


    ok(chdir $statusref->{cwd},
        "changed back to original directory");
} # end SKIP block


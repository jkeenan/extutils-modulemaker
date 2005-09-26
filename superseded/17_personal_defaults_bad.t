# t/17_personal_defaults_bad.t
use strict;
use Test::More tests => 18;

BEGIN { use_ok('ExtUtils::ModuleMaker'); }
BEGIN { use_ok('Cwd'); }
BEGIN { use_ok('IO::Capture::Stderr'); }

SKIP: {
    eval { require 5.006_001 };
    skip "tests require File::Temp, core with 5.6", 15 if $@;
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
        # provide name and call for compact top-level directory
        # but use a .modulemakerrc file which contains only bad values
        # (NAME and ABSTRACT)

        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my ($capture, @lines, $caught, $other_one);
        $capture = IO::Capture::Stderr->new();
        $capture->start();
        $mod = ExtUtils::ModuleMaker->new( 
            NAME              => 'XYZ::ABC',
            COMPACT           => 1,
            PERSONAL_DEFAULTS => "$cwd/t/testlib/02.sample.modulemakerrc",
        );
        $capture->stop();
        @lines = $capture->read();
        like($lines[0], qr/
            ^Module\s
            (ABSTRACT|NAME)
            \scannot\sbe\ssaved\sin\spersonal\sdefault\sfile;
            /x,
            "first warning correctly predicted");
        $lines[0] =~ /.*?(ABSTRACT|NAME)/;
        $caught = $1;
        $other_one = ($caught eq 'ABSTRACT') ? 'NAME' : 'ABSTRACT';
        like($lines[1], qr/
            ^Module\s
            $other_one
            \scannot\sbe\ssaved\sin\spersonal\sdefault\sfile;
            /x,
            "second warning correctly predicted");
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
            "A\.\\sU\.\\sThor",
            "a\.u\.thor\@a\.galaxy\.far\.far\.away",
            "Module\\sabstract\\s\\(<=\\s44\\scharacters\\)\\sgoes\\shere",
        );
        check_MakefilePL($topdir, \@pred);
        ok(chdir $cwd, 'changed back to original directory after testing');
    }


    ok(chdir $statusref->{cwd},
        "changed back to original directory");
} # end SKIP block


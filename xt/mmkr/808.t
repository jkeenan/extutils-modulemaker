# t/mmkr/806.t
use strict;
use warnings;
use Test::More tests => 26;
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
        _save_pretesting_status
        _restore_pretesting_status
        make_compact
        read_file_string
    )
);

my $statusref = _save_pretesting_status();

SKIP: {
    eval { require 5.006_001 };
    skip "tests require File::Temp, core with 5.6",
        (26 - 10) if $@;
    use warnings;
    use_ok( 'File::Temp', qw| tempdir |);

    # Simple tests of modulemaker utility in non-interactive mode

    my $cwd = $statusref->{cwd};
    my ($tdir, $module_name, $topdir, $pmfile, $filetext);

    {
        # provide name and call for compact top-level directory
        # call option to set VERSION to number other than 0.01
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        $module_name = 'XYZ::ABC';
        ok(! system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/modulemaker" -Icqn "$module_name" -v 0.3 }),
            "able to call modulemaker utility");

        ($topdir, $pmfile) = make_compact($module_name);
        ok(-d $topdir, "compact top directory created");
        ok(-f "$topdir/$_", "$_ file created")
            for qw| Changes LICENSE MANIFEST Makefile.PL README Todo |;
        ok(-d "$topdir/$_", "$_ directory created")
            for qw| lib t |;
        ok(-f $pmfile, "$pmfile created");

        ok($filetext = read_file_string($pmfile),
            "Able to read $pmfile");
        like($filetext, qr/\$VERSION\s+=\s+'0\.3'/,
            "VERSION number is correct and properly quoted");
    }

    ok(chdir $statusref->{cwd},
        "changed back to original directory");
} # end SKIP block

END {
    _restore_pretesting_status($statusref);
}


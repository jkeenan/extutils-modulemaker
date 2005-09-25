# t/mmkr/807.t
use strict;
local $^W = 1;
use Test::More tests => 25;
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
        _save_pretesting_status
        _restore_pretesting_status
        make_compact
        check_pm_file
    )
);

my $statusref = _save_pretesting_status();

SKIP: {
    eval { require 5.006_001 };
    skip "tests require File::Temp, core with 5.6", 
        (25 - 2) if $@;
    use warnings;
    use_ok( 'File::Temp', qw| tempdir |);

    # Simple tests of modulemaker utility in non-interactive mode

    my $cwd = $statusref->{cwd};
    my ($tdir, $module_name, $topdir, $pmfile, %pred);

    { 
        # provide name and call for compact top-level directory
        # call option to omit constructor (sub new()) from .pm file
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        $module_name = 'XYZ::ABC';
        ok(! system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/modulemaker" -Icqn "$module_name" }),
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
    }

} # end SKIP block

END {
    _restore_pretesting_status($statusref);
}



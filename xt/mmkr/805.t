# t/mmkr/805.t
use strict;
use warnings;
use Test::More tests => 24;
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
        _save_pretesting_status
        _restore_pretesting_status
        check_MakefilePL
    )
);

my $statusref = _save_pretesting_status();

SKIP: {
    eval { require 5.006_001 };
    skip "tests require File::Temp, core with 5.6",
        (24 - 10) if $@;
    use warnings;
    use_ok( 'File::Temp', qw| tempdir |);

    # Simple tests of modulemaker utility in non-interactive mode

    my $cwd = $statusref->{cwd};
    my ($tdir, $topdir, @pred);

    {
        # provide name and call for compact top-level directory
        # add in abstract and author-name and e-mail
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        ok(! system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/modulemaker" -Icn XYZ::ABC -a \"This is very abstract.\" -u \"John Q Public\" -e jqpublic\@calamity.jane.net}),   #"
            "able to call modulemaker utility with abstract");

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
    }


    ok(chdir $statusref->{cwd},
        "changed back to original directory");
} # end SKIP block

END {
    _restore_pretesting_status($statusref);
}


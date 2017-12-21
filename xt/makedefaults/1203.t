# t/makedefaults/1203.t
# tests of options to make modulemaker selections default personal values
use strict;
use warnings;
use Test::More tests => 37;
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
        (37 - 10) if $@;
    use warnings;
    use_ok( 'File::Temp', qw| tempdir |);

    my $cwd = $statusref->{cwd};
    my ($tdir, $topdir, @pred);

    {
        # same test as 12-2, only using modulemaker utility in
        # non-interactive mode to set Testing::Defaults as temporary
        # Personal::Defaults
        # PROBLEM:  This will not work because setting the -t option for
        # Testing::Defaults supersedes all other arguments to modulemaker
        # Additional problem:  modulemaker both constructs and builds, but it
        # does not return an object on which I can call
        # make_selections_defaults().  Can I get around this by incorporating
        # that method into complete_build() -- so far so good -- and by
        # defining a modulemaker option therefor?  Okay, but then I cannot
        # have the -t option wiping out everything else due to the positioning
        # of the processing of $self->{TESTING_DEFAULTS_FILE} inside
        # EU::MM::new().

        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        ok(! system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/modulemaker" -Isn EU::MM::Testing::Defaults -a "Module abstract (<= 44 characters) goes here" -u "Hilton Stallone" -p RAMBO -o "Parliamentary Pictures" -w http://parliamentarypictures.com -e hiltons\@parliamentarypictures.com }),
            "able to call modulemaker utility with save defaults option on");

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

        ok(-f "$statusref->{mmkr_dir}/$statusref->{pers_file}",
            "new Personal::Defaults installed");

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

    }

    ok(chdir $statusref->{cwd},
        "changed back to original directory");
} # end SKIP block

END {
    _restore_pretesting_status($statusref);
}


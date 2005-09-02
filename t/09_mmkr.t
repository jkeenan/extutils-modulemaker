# t/09_mmkr.t
use strict;
local $^W = 1;
use Test::More 
# tests => 144;
qw(no_plan);
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'Cwd');
use_ok( 'ExtUtils::ModuleMaker::Utility', qw( 
        _preexists_mmkr_directory
        _make_mmkr_directory
        _restore_mmkr_dir_status
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
        (144 - 4) if $@;
    use warnings;
    use_ok( 'File::Temp', qw| tempdir |);
    use lib ("./t/testlib");
    use Auxiliary qw(
        check_MakefilePL 
        check_pm_file
        make_compact
    );

    # Simple tests of modulemaker utility in non-interactive mode

    my $cwd = cwd();
    my ($tdir, $topdir, @pred, $module_name, $pmfile, %pred);

    {
        # test against Testing::Defaults

        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        ok(! system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/modulemaker" -In EU::MM::Testing::Defaults -a "Module abstract (<= 44 characters) goes here" -u "Hilton Stallone" -p RAMBO -o "Parliamentary Pictures" -w http://parliamentarypictures.com -e hiltons\@parliamentarypictures.com }), 
            "able to call modulemaker utility");

        $topdir = "EU/MM/Testing/Defaults"; 
        ok(-d $topdir, "by default, non-compact top directory created");
        ok(-f "$topdir/$_", "$_ file created")
            for qw| Changes LICENSE MANIFEST Makefile.PL README Todo |;
        ok(-d "$topdir/$_", "$_ directory created")
            for qw| lib t |;
        
        @pred = (
            "EU::MM::Testing::Defaults",
            "lib\/EU\/MM\/Testing\/Defaults\.pm",
            "Hilton\\sStallone",
            "hiltons\@parliamentarypictures\.com",
            "Module\\sabstract\\s\\(<=\\s44\\scharacters\\)\\sgoes\\shere",
        );

        check_MakefilePL($topdir, \@pred);
        ok(chdir $cwd, 'changed back to original directory after testing');

        _reprocess_personal_defaults_file($pers_def_ref);

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");

    }

    {
        # suppress Personal::Defaults for duration of test
        # do not provide -t option
        # hence, you are testing against EU::MM::Defaults, which means you
        # must supply a NAME; you must also suppress interactive mode

        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        ok(! system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/modulemaker" -In My::Research::Module }), 
            "able to call modulemaker utility");

        $topdir = "My/Research/Module"; 
        ok(-d $topdir, "by default, non-compact top directory created");
        ok(-f "$topdir/$_", "$_ file created")
            for qw| Changes LICENSE MANIFEST Makefile.PL README Todo |;
        ok(-d "$topdir/$_", "$_ directory created")
            for qw| lib t |;
        
        @pred = (
            "My::Research::Module",
            "lib\/My\/Research\/Module\.pm",
            "A\.\\sU\.\\sThor",
            "a\.u\.thor\@a\.galaxy\.far\.far\.away",
            "Module\\sabstract\\s\\(<=\\s44\\scharacters\\)\\sgoes\\shere",
        );

        check_MakefilePL($topdir, \@pred);

        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $cwd, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");

    }


    {
        # provide name and call for compact top-level directory
        # add in abstract
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        ok(! system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/modulemaker" -Icn XYZ::ABC -a \"This is very abstract.\"}),  #"
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
            "A\.\\sU\.\\sThor",
            "a\.u\.thor\@a\.galaxy\.far\.far\.away",
            "This\\sis\\svery\\sabstract\.",
        );
        check_MakefilePL($topdir, \@pred);

        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $cwd, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");

    }

    {
        # provide name and call for compact top-level directory
        # add in abstract and author-name
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        ok(! system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/modulemaker" -Icn XYZ::ABC -a \"This is very abstract.\" -u \"John Q Public\"}), #"
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
            "a\.u\.thor\@a\.galaxy\.far\.far\.away",
            "This\\sis\\svery\\sabstract\.",
        );
        check_MakefilePL($topdir, \@pred);

        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $cwd, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");

    }

    {
        # provide name and call for compact top-level directory
        # add in abstract and author-name and e-mail
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

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

        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $cwd, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");

    }

    {
        # provide name and call for compact top-level directory
        # call option to omit POD from .pm file
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        $module_name = 'XYZ::ABC';
        ok(! system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/modulemaker" -IcPn "$module_name" }),
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

        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $cwd, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");

    }

    {
        # provide name and call for compact top-level directory
        # call option to omit constructor (sub new()) from .pm file
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

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

        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $cwd, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");

    }

} # end SKIP block

=for PersonalDefaultsProblem
    With a Personal Defaults file stored on the system, the test below picks
up the Testing Defaults file and demonstrates that its data is correctly
reflected in the files generated.  However, as the data coming from the 
Testing Defaults file supersedes all other input data -- including wiping out
any other command-line options -- it is inflexible, i.e., I can't test it for,
say, compact top-level directory because it's hard coded for non-compact.  All
that it really demonstrates is that, with a Personal Defaults file on the
system, data supplied to the constructor after the Personal Defaults file
enters correctly.
    The only way around this will be to SUPPRESS the system Personal Defaults
file, allow the EU::MM::Defaults to come in as modified by command-line
options.  When I do that suppression, I must make sure to record its last
modification time and to restore that time when the file is restored.
    8/25:  Working on t/09_mmkr.t.  I got the TESTING_DEFAULTS_FILE to work in the case where a Personal Defaults file is present on the system.  But I noted in a comment that this is an inflexible and not very useful feature.  Still to be done:  temporary suppression of the system Personal Defaults so that user-specified values (via arguments to constructor or via command-line options to modulemaker) can be tested.

=cut


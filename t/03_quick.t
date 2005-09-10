# t/03_quick.t
use strict;
local $^W = 1;
use Test::More 
tests => 37;
# qw(no_plan);
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'Cwd');
use_ok( 'ExtUtils::ModuleMaker::Utility', qw( 
        _preexists_mmkr_directory
        _make_mmkr_directory
        _restore_mmkr_dir_status
    )
);
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
        _process_personal_defaults_file 
        _reprocess_personal_defaults_file 
    )
);

my $odir = cwd();

SKIP: {
    eval { require 5.006_001 };
    skip "tests require File::Temp, core with Perl 5.6", 
        (37 - 4) if $@;
    use warnings;
    use_ok( 'File::Temp', qw| tempdir |);
    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    ###########################################################################

    my $mmkr_dir_ref = _preexists_mmkr_directory();
    my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
    ok( $mmkr_dir, "personal defaults directory now present on system");

    my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
    my $pers_def_ref = 
        _process_personal_defaults_file( $mmkr_dir, $pers_file );

    my $mod;

    ok($mod  = ExtUtils::ModuleMaker->new ( NAME => 'Sample::Module'),
        "call ExtUtils::ModuleMaker->new for Sample-Module");
        
    ok( $mod->complete_build(), 'call complete_build()' );

    ########################################################################

    ok(chdir "Sample/Module",
        "cd Sample/Module");

    for (qw/Changes MANIFEST Makefile.PL LICENSE
            README lib t/) {
        ok (-e,
            "$_ exists");
    }

    ########################################################################

    my $filetext;
    {
        local *FILE;
        ok(open (FILE, 'LICENSE'),
            "reading 'LICENSE'");
        $filetext = do {local $/; <FILE>};
        close FILE;
    }

    ok($filetext =~ m/Terms of Perl itself/,
        "correct LICENSE generated");

    ########################################################################

    # tests of inheritability of constructor
    # note:  attributes must not be thought of as inherited because
    # constructor freshly repopulates data structure with default values

    my ($modparent, $modchild, $modgrandchild);

    ok($modparent  = ExtUtils::ModuleMaker->new(
        NAME => 'Sample::Module',
        ABSTRACT => 'The quick brown fox'
    ), "call ExtUtils::ModuleMaker->new for Sample-Module");
    isa_ok($modparent, "ExtUtils::ModuleMaker", "object is an EU::MM object");
    is($modparent->{NAME}, 'Sample::Module', "NAME is correct");
    is($modparent->{ABSTRACT}, 'The quick brown fox', "ABSTRACT is correct");

    $modchild = $modparent->new(
        'NAME'     => 'Alpha::Beta',
        ABSTRACT => 'The quick brown fox'
    );
    isa_ok($modchild, "ExtUtils::ModuleMaker", "constructor is inheritable");
    is($modchild->{NAME}, 'Alpha::Beta', "new NAME is correct");
    is($modchild->{ABSTRACT}, 'The quick brown fox', 
        "ABSTRACT was correctly inherited");

    ok($modgrandchild  = $modchild->new(
        NAME => 'Gamma::Delta',
        ABSTRACT => 'The quick brown vixen'
    ), "call ExtUtils::ModuleMaker->new for Sample-Module");
    isa_ok($modgrandchild, "ExtUtils::ModuleMaker", "object is an EU::MM object");
    is($modgrandchild->{NAME}, 'Gamma::Delta', "NAME is correct");
    is($modgrandchild->{ABSTRACT}, 'The quick brown vixen', 
        "explicitly coded ABSTRACT is correct");

    _reprocess_personal_defaults_file($pers_def_ref);

    ok(chdir $odir, 'changed back to original directory after testing');

    ok( _restore_mmkr_dir_status($mmkr_dir_ref),
        "original presence/absence of .modulemaker directory restored");

} # end SKIP block



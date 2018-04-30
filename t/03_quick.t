# t/03_quick.t
use strict;
use warnings;
use Test::More qw(no_plan); # tests => 32;
use Cwd;
use File::Temp qw(tempdir);
use_ok( 'ExtUtils::ModuleMaker' );
use lib ( qw| ./t/testlib | );
use_ok( 'MockHomeDir' );

my ($home_dir, $personal_defaults_dir);
$home_dir = MockHomeDir::home_dir();
ok(-d $home_dir, "Directory $home_dir created to mock home directory");
$personal_defaults_dir = MockHomeDir::personal_defaults_dir();
ok(-d $personal_defaults_dir, "Able to create directory $personal_defaults_dir for testing");

local $ENV{HOME} = $home_dir;

note("Case 1: No personal defaults file");

#{
#    my $cwd = cwd();
#
#    my $tdir = tempdir( CLEANUP => 1);
#    ok(chdir $tdir, 'changed to temp directory for testing');
#
#    ###########################################################################
#
#    my $mod;
#
#    ok($mod  = ExtUtils::ModuleMaker->new ( NAME => 'Sample::Module'),
#        "call ExtUtils::ModuleMaker->new for Sample-Module");
#
#    ok( $mod->complete_build(), 'call complete_build()' );
#
#    ########################################################################
#
#    ok(chdir "Sample/Module",
#        "cd Sample/Module");
#
#    for (qw/Changes MANIFEST Makefile.PL LICENSE
#            README lib t/) {
#        ok (-e,
#            "$_ exists");
#    }
#
#    ########################################################################
#
#    my $filetext;
#    {
#        local *FILE;
#        ok(open (FILE, 'LICENSE'),
#            "reading 'LICENSE'");
#        $filetext = do {local $/; <FILE>};
#        close FILE;
#    }
#
#    ok($filetext =~ m/Terms of Perl itself/,
#        "correct LICENSE generated");
#
#    ok(chdir $tdir, 'change back to previous temp directory');
#
#    ########################################################################
#
#    # tests of inheritability of constructor
#    # note:  attributes must not be thought of as inherited because
#    # constructor freshly repopulates data structure with default values
#
#    my ($modparent, $modchild, $modgrandchild);
#
#    ok($modparent  = ExtUtils::ModuleMaker->new(
#        NAME => 'Sample::Module',
#        ABSTRACT => 'The quick brown fox'
#    ), "call ExtUtils::ModuleMaker->new for Sample-Module");
#    isa_ok($modparent, "ExtUtils::ModuleMaker", "object is an EU::MM object");
#    is($modparent->{NAME}, 'Sample::Module', "NAME '$modparent->{NAME}' is correct");
#    is($modparent->{ABSTRACT}, 'The quick brown fox', "ABSTRACT '$modparent->{ABSTRACT}' is correct");
#    is($modparent->{AUTHOR}, 'A. U. Thor', "AUTHOR '$modparent->{AUTHOR}' is correct");
#
#    $modchild = $modparent->new(
#        'NAME'     => 'Alpha::Beta',
#        ABSTRACT => 'The quick brown fox'
#    );
#    isa_ok($modchild, "ExtUtils::ModuleMaker", "constructor is inheritable");
#    is($modchild->{NAME}, 'Alpha::Beta', "child NAME '$modchild->{NAME}' is correct");
#    is($modchild->{ABSTRACT}, 'The quick brown fox', "child ABSTRACT '$modchild->{ABSTRACT}' is correct");
#    is($modchild->{AUTHOR}, 'A. U. Thor', "child AUTHOR '$modchild->{AUTHOR}' is correct");
#
#    ok($modgrandchild  = $modchild->new(
#        NAME => 'Gamma::Delta',
#        ABSTRACT => 'The quick brown vixen'
#    ), "call ExtUtils::ModuleMaker->new for Sample-Module");
#    isa_ok($modgrandchild, "ExtUtils::ModuleMaker", "object is an EU::MM object");
#    is($modgrandchild->{NAME}, 'Gamma::Delta', "grandchild NAME '$modgrandchild->{NAME}' is correct");
#    is($modgrandchild->{ABSTRACT}, 'The quick brown vixen', "grandchild's explicitly coded ABSTRACT is correct");
#    is($modgrandchild->{AUTHOR}, 'A. U. Thor', "grandchild AUTHOR '$modgrandchild->{AUTHOR}' is correct");
#
#    ok(chdir $cwd, "Changed back to original directory");
#}

note("Case 2: Personal defaults file present");

my $personal_defaults_file = MockHomeDir::personal_defaults_file();
ok(-f $personal_defaults_file, "Able to create file $personal_defaults_file for testing");

{
    my $cwd = cwd();

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    ###########################################################################

#    my $mod;
#
#    ok($mod  = ExtUtils::ModuleMaker->new ( NAME => 'Sample::Module'),
#        "call ExtUtils::ModuleMaker->new for Sample-Module");
#
#    ok( $mod->complete_build(), 'call complete_build()' );
#
#    ########################################################################
#
#    ok(chdir "Sample/Module",
#        "cd Sample/Module");
#
#    for (qw/Changes MANIFEST Makefile.PL LICENSE
#            README lib t/) {
#        ok (-e,
#            "$_ exists");
#    }
#
#    ########################################################################
#
#    my $filetext;
#    {
#        local *FILE;
#        ok(open (FILE, 'LICENSE'),
#            "reading 'LICENSE'");
#        $filetext = do {local $/; <FILE>};
#        close FILE;
#    }
#
#    ok($filetext =~ m/Terms of Perl itself/,
#        "correct LICENSE generated");
#
#    ok(chdir $tdir, 'change back to previous temp directory');

    ########################################################################

    # tests of inheritability of constructor
    # note:  attributes must not be thought of as inherited because
    # constructor freshly repopulates data structure with default values

    my ($modparent, $modchild, $modgrandchild);

    #        ABSTRACT         => q{Module abstract (<= 44 characters) goes here},
    #    AUTHOR           => q{Hilton Stallone},
    ok($modparent  = ExtUtils::ModuleMaker->new(
        NAME => 'Sample::Module',
        debug => 1,
    ), "call ExtUtils::ModuleMaker->new for Sample-Module");
    isa_ok($modparent, "ExtUtils::ModuleMaker", "object is an EU::MM object");
    is($modparent->{NAME}, 'Sample::Module', "NAME '$modparent->{NAME}' is correct");
    is($modparent->{ABSTRACT}, q{Module abstract (<= 44 characters) goes here}, "ABSTRACT '$modparent->{ABSTRACT}' is correct");
    is($modparent->{AUTHOR}, q{Hilton Stallone}, "AUTHOR '$modparent->{AUTHOR}' is correct");

    $modchild = $modparent->new(
        'NAME'     => 'Alpha::Beta',
        ABSTRACT => 'The quick brown fox',
        debug => 1,
    );
    isa_ok($modchild, "ExtUtils::ModuleMaker", "constructor is inheritable");
    is($modchild->{NAME}, 'Alpha::Beta', "child NAME '$modchild->{NAME}' is correct");
    is($modchild->{ABSTRACT}, 'The quick brown fox', "child ABSTRACT '$modchild->{ABSTRACT}' is correct");
    is($modchild->{AUTHOR}, q{Hilton Stallone}, "child AUTHOR '$modchild->{AUTHOR}' is correct");

    ok($modgrandchild  = $modchild->new(
        NAME => 'Gamma::Delta',
        ABSTRACT => 'The quick brown vixen',
        debug => 1,
    ), "call ExtUtils::ModuleMaker->new for Sample-Module");
    isa_ok($modgrandchild, "ExtUtils::ModuleMaker", "object is an EU::MM object");
    is($modgrandchild->{NAME}, 'Gamma::Delta', "grandchild NAME '$modgrandchild->{NAME}' is correct");
    is($modgrandchild->{ABSTRACT}, 'The quick brown vixen',
        "grandchild's explicitly coded ABSTRACT is correct");
    is($modgrandchild->{AUTHOR}, q{Hilton Stallone}, "grandchild AUTHOR '$modgrandchild->{AUTHOR}' is correct");

    ok(chdir $cwd, "Changed back to original directory");
}



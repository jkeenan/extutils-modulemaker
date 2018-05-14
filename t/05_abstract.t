# t/05_abstract.t
use strict;
use warnings;
use Carp;
use File::Spec;
use File::Temp qw(tempdir);
use Test::More tests =>  24;
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
    prepare_mockdirs
    read_file_string
    five_file_tests
) );

{
    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    ########################################################################

    my $mod;
    my $testmod = 'Beta';

    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);

    ok( $mod = ExtUtils::ModuleMaker->new( 
            NAME           => $module_name,
            ABSTRACT       => 'Test of the capacities of EU::MM',
            COMPACT        => 1,
            CHANGES_IN_POD => 1,
            AUTHOR         => 'Phineas T. Bluster',
            CPANID         => 'PTBLUSTER',
            ORGANIZATION   => 'Peanut Gallery',
            WEBSITE        => 'http://www.anonymous.com/~phineas',
            EMAIL          => 'phineas@anonymous.com',
        ),
        "call ExtUtils::ModuleMaker->new for $dist_name"
    );

    ok( $mod->complete_build(), 'call complete_build()' );

    for my $f ( qw| MANIFEST Makefile.PL LICENSE README | ) {
        my $ff = File::Spec->catfile($dist_name, $f);
        ok (-e $ff, "$ff exists");
    }
    ok(! -f File::Spec->catfile($dist_name, 'Changes'),
        "Changes file not created");
    for my $d ( qw| lib scripts t | ) {
        my $dd = File::Spec->catdir($dist_name, $d);
        ok(-d $dd, "Directory '$dd' exists");
    }   

    my ($filetext);
    ok($filetext = read_file_string(File::Spec->catfile($dist_name, 'Makefile.PL')),
        'Able to read Makefile.PL');
    ok($filetext =~ m|AUTHOR\s+=>\s+.Phineas\sT.\sBluster|,
        'Makefile.PL contains correct author') or diag($filetext);
    ok($filetext =~ m|AUTHOR.*\(phineas\@anonymous\.com\)|,
        'Makefile.PL contains correct e-mail');
    ok($filetext =~ m|ABSTRACT\s+=>\s+'Test\sof\sthe\scapacities\sof\sEU::MM'|,
        'Makefile.PL contains correct abstract');

    five_file_tests(7, \@components); # first arg is # entries in MANIFEST
}


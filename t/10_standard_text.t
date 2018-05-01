# t/10_standard_text.t
# tests of importation of standard text from
# lib/ExtUtils/Modulemaker/Defaults.pm
use strict;
use warnings;
use Carp;
use File::Spec;
use File::Temp qw(tempdir);
use Test::More tests =>   30;
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
    prepare_mockdirs
    basic_file_and_directory_tests
    license_text_test
    read_file_string
    read_file_array
) );


{
    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my ($mod);
    my $testmod = 'Beta';
    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    
    ok( $mod = ExtUtils::ModuleMaker->new( 
            NAME           => $module_name,
            COMPACT        => 1,
        ),
        "call ExtUtils::ModuleMaker->new for $dist_name"
    );
    
    ok( $mod->complete_build(), 'call complete_build()' );

    basic_file_and_directory_tests($dist_name);
    license_text_test($dist_name, qr/Terms of Perl itself/);

    my ($filetext, @pmfilelines, @makefilelines, @readmelines);

    ok(@pmfilelines = read_file_array(File::Spec->catfile(
            $dist_name,
            'lib',
            @components[0 .. ($#components - 1)],
            "$components[-1].pm",
        ) ),
        'Able to read module into array');

    # test of main pod wrapper
    is( (grep {/^#{20} main pod documentation (begin|end)/} @pmfilelines), 2, 
        "standard text for POD wrapper found");

    # test of block new method
    is( (grep {/^sub new/} @pmfilelines), 1, 
        "new method found");

    # test of block module header description
    is( (grep {/^sub new/} @pmfilelines), 1, 
        "new method found");

    # test of stub documentation
    is( (grep {/^Stub documentation for this module was created/} @pmfilelines), 
        1, 
        "stub documentation found");

    # test of subroutine header
    is( (grep {/^#{20} subroutine header (begin|end)/} @pmfilelines), 2, 
        "subroutine header found");

    # test of final block
    is( (grep { /^(1;|# The preceding line will help the module return a true value)$/ } @pmfilelines), 2, 
        "final module block found");

    # test of Makefile.PL text
    ok($filetext = read_file_string(File::Spec->catfile($dist_name, 'Makefile.PL')),
        'Able to read Makefile.PL');

    ok(@makefilelines = read_file_array(File::Spec->catfile($dist_name, 'Makefile.PL')),
        'Able to read Makefile.PL into array');
    is( (grep {/^# See lib\/ExtUtils\/MakeMaker.pm for details of how to influence/} @makefilelines), 1, 
        "Makefile.PL has standard text");

    # test of README text
    ok(@readmelines = read_file_array(File::Spec->catfile($dist_name, 'README')),
        'Able to read README into array');

    is( (grep {/^pod2text $mod->{NAME}/} @readmelines),
        1,
        "README has correct pod2text line");
    is( (grep {/^If this is still here/} @readmelines),
        1,
        "README has correct top part");
    is( (grep {/^(perl Makefile\.PL|make( (test|install))?)/} @readmelines), 
        4, 
        "README has appropriate build instructions for MakeMaker");
    is( (grep {/^If you are on a windows box/} @readmelines),
        1,
        "README has correct bottom part");
}

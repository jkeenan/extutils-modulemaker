# t/11_standard_text.t
# tests of importation of standard text from
# lib/ExtUtils/Modulemaker/Defaults.pm

use Test::More qw(no_plan);
use strict;
local $^W = 1;

BEGIN { use_ok('ExtUtils::ModuleMaker'); }
BEGIN { use_ok( 'File::Temp', qw| tempdir |); }
BEGIN { use_ok( 'Cwd' ); }
use lib ("./t/testlib");
use _Auxiliary qw(
    read_file_string
    read_file_array
);

my $odir = cwd();
my ($tdir, $mod, $testmod, $filetext, @filelines);

########################################################################

{   
    $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');
    $testmod = 'Beta';
    
    ok( $mod = ExtUtils::ModuleMaker->new( 
            NAME           => "Alpha::$testmod",
            COMPACT        => 1,
        ),
        "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
    );
    
    ok( $mod->complete_build(), 'call complete_build()' );

    ok( -d qq{Alpha-$testmod}, "compact top-level directory exists" );
    ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );
    ok( -d, "directory $_ exists" ) for ( qw/lib scripts t/);
    ok( -f, "file $_ exists" )
        for ( qw/Changes LICENSE Makefile.PL MANIFEST README Todo/);
    ok( -f, "file $_ exists" )
        for ( "lib/Alpha/${testmod}.pm", "t/001_load.t" );
    
    ok($filetext = read_file_string('Makefile.PL'),
        'Able to read Makefile.PL');
    ok(@filelines = read_file_array("lib/Alpha/${testmod}.pm"),
        'Able to read module into array');

    # test of main pod wrapper
    is( (grep {/^#{20} main pod documentation (begin|end)/} @filelines), 2, 
        "standard text for POD wrapper found");

    # test of block new method
    is( (grep {/^sub new/} @filelines), 1, 
        "new method found");

    # test of block module header description
    is( (grep {/^sub new/} @filelines), 1, 
        "new method found");

    # test of stub documentation
    is( (grep {/^Stub documentation for this module was created/} @filelines), 
        1, 
        "stub documentation found");

    # test of subroutine header
    is( (grep {/^#{20} subroutine header (begin|end)/} @filelines), 2, 
        "subroutine header found");

    # test of final block
    is( (grep { /^(1;|# The preceding line will help the module return a true value)$/ } @filelines), 2, 
        "final module block found");

    ok(chdir $odir, 'changed back to original directory after testing');
}
 

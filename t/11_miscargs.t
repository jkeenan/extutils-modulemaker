# t/11_miscargs.t
# tests of miscellaneous arguments passed to constructor

use Test::More 
# tests => 27;
qw(no_plan);
use strict;
local $^W = 1;

BEGIN { use_ok('ExtUtils::ModuleMaker'); }
BEGIN { use_ok( 'File::Temp', qw| tempdir |); }
BEGIN { use_ok( 'Cwd' ); }
use lib ("./t/testlib");
BEGIN { use_ok( 'IO::Capture::Stdout' ); }
use _Auxiliary qw(
    read_file_string
);

my $odir = cwd();
my $tdir = tempdir( CLEANUP => 1);
ok(chdir $tdir, 'changed to temp directory for testing');
my ($mod, $testmod, $filetext);

########################################################################

{
    $testmod = 'Beta';
    
    ok( $mod = ExtUtils::ModuleMaker->new( 
            NAME           => "Alpha::$testmod",
            COMPACT        => 1,
            VERBOSE        => 1,
        ),
        "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
    );
    
    my ($capture, %count);
    $capture = IO::Capture::Stdout->new();
    $capture->start();
    ok( $mod->complete_build(), 'call complete_build()' );
    $capture->stop();
    for my $l ($capture->read()) {
        $count{'mkdir'}++ if $l =~ /^mkdir/;
        $count{'writing'}++ if $l =~ /^writing file/;
    }
    is($count{'mkdir'}, 5, "correct no. of directories created announced verbosely");
    is($count{'writing'}, 8, "correct no. of files created announced verbosely");

    ok( -d qq{Alpha-$testmod}, "compact top-level directory exists" );
    ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );
    ok( -d, "directory $_ exists" ) for ( qw/lib scripts t/);
    ok( -f, "file $_ exists" )
        for ( qw/Changes LICENSE Makefile.PL MANIFEST README Todo/);
    ok( -f, "file $_ exists" )
        for ( "lib/Alpha/${testmod}.pm", "t/001_load.t" );
    
    ok($filetext = read_file_string('Makefile.PL'),
        'Able to read Makefile.PL');
    
    ok(chdir $odir, 'changed back to original directory after testing');
}
 
{
    $testmod = 'Gamma';
    
    ok( $mod = ExtUtils::ModuleMaker->new( 
            NAME           => "Alpha::$testmod",
            COMPACT        => 0,
            VERBOSE        => 1,
        ),
        "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
    );
    
    my ($capture, %count);
    $capture = IO::Capture::Stdout->new();
    $capture->start();
    ok( $mod->complete_build(), 'call complete_build()' );
    $capture->stop();
    for my $l ($capture->read()) {
        $count{'mkdir'}++ if $l =~ /^mkdir/;
        $count{'writing'}++ if $l =~ /^writing file/;
    }
    is($count{'mkdir'}, 6, "correct no. of directories created announced verbosely");
    is($count{'writing'}, 8, "correct no. of files created announced verbosely");

    ok( -d qq{Alpha/$testmod}, "non-compact top-level directories exist" );
    ok( chdir "Alpha/$testmod", "cd Alpha/$testmod" );
    ok( -d, "directory $_ exists" ) for ( qw/lib scripts t/);
    ok( -f, "file $_ exists" )
        for ( qw/Changes LICENSE Makefile.PL MANIFEST README Todo/);
    ok( -f, "file $_ exists" )
        for ( "lib/Alpha/${testmod}.pm", "t/001_load.t" );
    
    ok($filetext = read_file_string('Makefile.PL'),
        'Able to read Makefile.PL');
    
    ok(chdir $odir, 'changed back to original directory after testing');
}
 

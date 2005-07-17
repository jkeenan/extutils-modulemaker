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
my ($tdir, $mod, $testmod, $filetext);

########################################################################
# Sets 1 and 2:  Test VERBOSE => 1 to make sure that logging messages
# note each directory and file created. 1:  Compact top directory.
# 2:  Non-compact top directory.

{   # Set 1
    $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');
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
 
{   # Set 2
    $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');
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
    ok( -d, "directory $_ exists" ) for ( qw/lib lib\/Alpha scripts t/);
    ok( -f, "file $_ exists" )
        for ( qw/Changes LICENSE Makefile.PL MANIFEST README Todo/);
    ok( -f, "file $_ exists" )
        for ( "lib/Alpha/${testmod}.pm", "t/001_load.t" );
    
    ok($filetext = read_file_string('Makefile.PL'),
        'Able to read Makefile.PL');
    
    ok(chdir $odir, 'changed back to original directory after testing');
}

{   # Set 3:  Test of new partial_dump() method.
    $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');
    $testmod = 'Rho';
    
    ok( $mod = ExtUtils::ModuleMaker->new( 
            NAME           => "Alpha::$testmod",
            COMPACT        => 0,
            VERBOSE        => 1,
        ),
        "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
    );
    
    my $dump;
    ok( $dump = $mod->partial_dump(qw| LicenseParts USAGE_MESSAGE |), 
        'call partial_dump()' );
    my @dumplines = split(/\n/, $dump);
    my $excluded_keys_flag = 0;
    for my $m ( @dumplines ) {
        $excluded_keys_flag++ if $m =~ /^\s+'(LicenseParts|USAGE_MESSAGE)/;
    } #'
    is($excluded_keys_flag, 0, 
        "keys intended to be excluded were excluded");
    
    ok(chdir $odir, 'changed back to original directory after testing');
}

##### Sets 4 & 5:  Tests of NEED_POD and NEED_NEW_METHOD options #####

{
    $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');
    $testmod = 'Phi';
    
    ok( $mod = ExtUtils::ModuleMaker->new( 
            NAME           => "Alpha::$testmod",
            COMPACT        => 1,
            NEED_POD       => 0,
        ),
        "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
    );
    
    ok(chdir $odir, 'changed back to original directory after testing');
}
    
 

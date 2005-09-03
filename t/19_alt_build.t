# t/19_alt_build.t
# test whether methods overriding those provided by EU::MM::StandardText
# create files as intended
use strict;
local $^W = 1;
use vars qw( @INC );
use Test::More 
# tests =>  199;
qw(no_plan);
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'Cwd');
use_ok( 'ExtUtils::ModuleMaker::Utility', qw( 
        _preexists_mmkr_directory
        _make_mmkr_directory
        _restore_mmkr_dir_status
        _identify_pm_files_in_personal_dir
        _hide_pm_files_in_personal_dir
        _reveal_pm_files_in_personal_dir
    )
);
use lib ("./t/testlib");
#my $cwd = cwd();
#warn $cwd;
#use lib ($cwd ."t/testlib");
use_ok( 'Auxiliary', qw(
        read_file_string
        read_file_array
        _process_personal_defaults_file 
        _reprocess_personal_defaults_file 
        _tests_pm_hidden
    )
);
use_ok( 'File::Copy' );
use Data::Dumper;


SKIP: {
    eval { require 5.006_001 };
    skip "tests require File::Temp, core with 5.6", 
        (199 - 5) if $@;
    use warnings;
    use_ok( 'File::Temp', qw| tempdir |);
    use_ok( 'IO::Capture::Stdout' );

    my $odir = cwd();
    my ($tdir, $mod, $testmod, $filetext, @filelines, %lines);

    ########################################################################

    {   # Set 1
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $persref;

        $persref = _identify_pm_files_in_personal_dir($mmkr_dir);
        _tests_pm_hidden($persref, { pm => 1, hidden => 0 });

        _hide_pm_files_in_personal_dir($persref);
        $persref = _identify_pm_files_in_personal_dir($mmkr_dir);
        _tests_pm_hidden($persref, { pm => 0, hidden => 1 });

# real tests go here
#warn "$_" for @INC;

        copy($odir/t/testlib/ExtUtils/ModuleMaker/Alternative/block_new_method.pm",
        $testmod = 'Beta';
        
#warn $_ for @INC;;        
        ok( $mod = ExtUtils::ModuleMaker->new( 
                NAME           => "Alpha::$testmod",
                COMPACT        => 1,
                ALT_BUILD      =>
                    q{ExtUtils::ModuleMaker::Alternative::block_new_method},
            ),
            "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
        );
warn $mod->dump_keys(qw| NAME AUTHOR COMPACT ALT_BUILD |);        
        ok( $mod->complete_build(), 'call complete_build()' );

#        ok( -d qq{Alpha-$testmod}, "compact top-level directory exists" );
#        ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );
#        ok( -d, "directory $_ exists" ) for ( qw/lib scripts t/);
#        ok( -f, "file $_ exists" )
#            for ( qw/Changes LICENSE Makefile.PL MANIFEST README Todo/);
#        ok( -f, "file $_ exists" )
#            for ( "lib/Alpha/${testmod}.pm", "t/001_load.t" );
        
        _reveal_pm_files_in_personal_dir($persref);
        $persref = _identify_pm_files_in_personal_dir($mmkr_dir);
        _tests_pm_hidden($persref, { pm => 1, hidden => 0 });

        ok(chdir $odir, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");

    }
     

} # end SKIP block

__END__

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

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
        
        _reprocess_personal_defaults_file($pers_def_ref);


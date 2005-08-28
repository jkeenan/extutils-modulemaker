# t/04_compact.t
use strict;
local $^W = 1;
use Test::More 
tests =>  24;
# qw(no_plan);
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'Cwd');
use_ok( 'ExtUtils::ModuleMaker::Utility', qw( 
        _get_personal_defaults_directory
    )
);
use lib ("./t/testlib");
use_ok( 'Auxiliary', qw(
        _process_personal_defaults_file 
        _reprocess_personal_defaults_file 
    )
);

my $odir = cwd();

SKIP: {
    eval { require 5.006_001 };
    skip "tests require File::Temp, core with Perl 5.6", 
        (24 - 4) if $@;
    use warnings;
    use_ok( 'File::Temp', qw| tempdir |);
    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    #######################################################################

    my $personal_dir = _get_personal_defaults_directory();
    my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
    my $pers_def_ref = 
        _process_personal_defaults_file( $personal_dir, $pers_file );

    my $mod;

    ok($mod  = ExtUtils::ModuleMaker->new
    			( 
    				NAME		=> 'Sample::Module::Foo',
    				COMPACT		=> 1,
    				LICENSE		=> 'looselips',
    			 ),
    	"call ExtUtils::ModuleMaker->new for Sample-Module-Foo");
    	
    ok( $mod->complete_build(), 'call complete_build()' );

    ########################################################################

    ok(chdir 'Sample-Module-Foo',
    	"cd Sample-Module-Foo");

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

    ok($filetext =~ m/Loose lips sink ships/,
    	"correct LICENSE generated");

    _reprocess_personal_defaults_file($pers_def_ref);

    ########################################################################

} # end SKIP block

ok(chdir $odir, 'changed back to original directory after testing');


# t/04_compact.t
use strict;
local $^W = 1;
use Test::More 
tests =>  24;
# qw(no_plan);
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
        _process_personal_defaults_file 
        _reprocess_personal_defaults_file 
        _save_pretesting_status
        _restore_pretesting_status
    )
);

my $statusref = _save_pretesting_status();

SKIP: {
    eval { require 5.006_001 };
    skip "tests require File::Temp, core with Perl 5.6", 
        (24 - 2) if $@;
    use warnings;
    use_ok( 'File::Temp', qw| tempdir |);
    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    #######################################################################

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

    ########################################################################

} # end SKIP block

END {
    _restore_pretesting_status($statusref);
}


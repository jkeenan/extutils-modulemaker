# t/04_compact.t
BEGIN {
    use Test::More 
    tests => 22;
#    qw(no_plan);
    $realhome = $ENV{HOME};
    local $ENV{HOME} = "./t/testlib/pseudohome";
    ok(-d $ENV{HOME}, "pseudohome directory exists");
    like($ENV{HOME}, qr/pseudohome/, "pseudohome identified");
    use_ok( 'File::Copy' );
    $personal_dir = "$ENV{HOME}/.modulemaker"; 
    $personal_defaults_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
    if (-f "$personal_dir/$personal_defaults_file") {
        move("$personal_dir/$personal_defaults_file", 
             "$personal_dir/$personal_defaults_file.bak"); 
        ok(-f "$personal_dir/$personal_defaults_file.bak",
            "personal defaults stored as .bak"); 
    } else {
        ok(1, "no personal defaults file found");
    }
    use_ok( 'ExtUtils::ModuleMaker' );
    use_ok( 'Cwd');
}
END {
    $ENV{HOME} = $realhome;
    if (-f "$personal_dir/$personal_defaults_file.bak") {
        move("$personal_dir/$personal_defaults_file.bak", 
             "$personal_dir/$personal_defaults_file"); 
        ok(-f "$personal_dir/$personal_defaults_file",
            "personal defaults restored"); 
    } else {
        ok(1, "no personal defaults file found");
    }
}
use strict;
local $^W = 1;

my $odir = cwd();

SKIP: {
    eval { require 5.006_001 };
    skip "tests require File::Temp, core with Perl 5.6", 15 if $@;
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

ok(chdir $odir, 'changed back to original directory after testing');


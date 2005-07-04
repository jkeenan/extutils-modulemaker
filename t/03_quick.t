# t/03_quick.t

use Test::More tests => 14;
use strict;
use warnings;

BEGIN { use_ok( 'ExtUtils::ModuleMaker' ); }
ok (chdir 'blib/testing' || chdir '../blib/testing', "chdir 'blib/testing'");

###########################################################################

my $mod;

ok ($mod  = ExtUtils::ModuleMaker->new ( {
                NAME        => 'Sample::Module',
            } ),
    "call ExtUtils::ModuleMaker->new for Sample-Module");
    
ok( $mod->complete_build(), 'call complete_build()' );

########################################################################

ok (chdir 'Sample/Module',
    "cd Sample/Module");

for (qw/Changes MANIFEST Makefile.PL LICENSE
        README lib t/) {
    ok (-e,
        "$_ exists");
}

########################################################################

ok (open (FILE, 'LICENSE'),
    "reading 'LICENSE'");
my $filetext = do {local $/; <FILE>};
close FILE;

ok ($filetext =~ m/Terms of Perl itself/,
    "correct LICENSE generated");

########################################################################


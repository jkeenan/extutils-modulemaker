# t/03_quick.t

use Test::More qw/no_plan/;
#use Test::More tests => 11;

BEGIN { use_ok( 'ExtUtils::ModuleMaker' ); }
ok (chdir 'blib/testing' || chdir '../blib/testing', "chdir 'blib/testing'");

###########################################################################

my $MOD;

ok ($MOD  = ExtUtils::ModuleMaker->new ( {
                NAME        => 'Sample::Module',
            } ),
    "call ExtUtils::ModuleMaker->new for Sample-Module");
    
ok ($MOD->complete_build (),
    "call $MOD->complete_build");

########################################################################

ok (chdir 'Sample/Module',
    "cd Sample/Module");

#        MANIFEST.SKIP .cvsignore
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


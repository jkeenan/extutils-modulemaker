# t/10_apostrophe.t

use Test::More 
# tests => 27;
qw(no_plan);
use strict;
local $^W = 1;

BEGIN { use_ok('ExtUtils::ModuleMaker'); }
BEGIN { use_ok( 'File::Temp', qw| tempdir |); }
BEGIN { use_ok( 'Cwd' ); }
use lib ("./t/testlib");
use _Auxiliary qw(
    read_file_string
    six_file_tests
);

my $odir = cwd();
my $tdir = tempdir( CLEANUP => 1);
my ($mod, $testmod, $filetext);
ok(chdir $tdir, 'changed to temp directory for testing');

########################################################################

{
    $testmod = 'Beta';
    
    ok( 
        $mod = ExtUtils::ModuleMaker->new( 
            NAME           => "D'uh'oh",
            ABSTRACT       => "Isn't this a good abstract?",
            COMPACT        => 1,
            CHANGES_IN_POD => 1,
            AUTHOR         => {
               'NAME'         => "Phineas T. O'Bluster",
               'CPANID'       => 'PTBLUSTER',
               'ORGANIZATION' => 'Peanut Gallery',
               'EMAIL'        => 'phineas@anonymous.com',
               'WEBSITE'      => 'http://www.anonymous.com/~phineas',
            },
        ),
        "call ExtUtils::ModuleMaker->new for D'uh'oh"
    );
    
    ok( $mod->complete_build(), 'call complete_build()' );
    
    ok( chdir "D-uh-oh", "cd D-uh-oh" );
    
    ok($filetext = read_file_string('Makefile.PL'),
        'Able to read Makefile.PL');
    like($filetext, qr|NAME.+D\\'uh\\'oh|,
        'Makefile.PL contains correct module name');
    like($filetext, qr|AUTHOR.+Phineas T. O\\'Bluster|,
        'Makefile.PL contains correct author');
    like($filetext, qr|AUTHOR.+\(phineas\@anonymous\.com\)|,
        'Makefile.PL contains correct e-mail');
    like($filetext, qr|ABSTRACT.+Isn\\'t this a good abstract?|,
        'Makefile.PL contains correct abstract');
    
    ok(chdir $odir, 'changed back to original directory after testing');
}


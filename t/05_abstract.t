# t/05_abstract.t

use Test::More tests => 25;
use strict;
local $^W = 1;

BEGIN { use_ok('ExtUtils::ModuleMaker'); }
BEGIN { use_ok( 'File::Temp', qw| tempdir |); }

use lib ("./t/testlib");
use _Auxiliary qw(
    read_file_string
    six_file_tests
);

my $tdir = tempdir( CLEANUP => 1);
ok(chdir $tdir, 'changed to temp directory for testing');

########################################################################

my $mod;
my $testmod = 'Beta';

ok( 
    $mod = ExtUtils::ModuleMaker->new( 
        NAME           => "Alpha::$testmod",
        ABSTRACT       => 'Test of the capacities of EU::MM',
        COMPACT        => 1,
        CHANGES_IN_POD => 1,
        AUTHOR         => {
           'NAME'         => 'Phineas T. Bluster',
           'CPANID'       => 'PTBLUSTER',
           'ORGANIZATION' => 'Peanut Gallery',
           'EMAIL'        => 'phineas@anonymous.com',
           'WEBSITE'      => 'http://www.anonymous.com/~phineas',
        },
    ),
    "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
);

ok( $mod->complete_build(), 'call complete_build()' );

ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );

for ( qw/LICENSE Makefile.PL MANIFEST README Todo/) {
    ok( -f, "file $_ exists" );
}
ok(! -f 'Changes', 'Changes file correctly not created');
for ( qw/lib scripts t/) {
    ok( -d, "directory $_ exists" );
}

my ($filetext);
ok($filetext = read_file_string('Makefile.PL'),
    'Able to read Makefile.PL');
ok($filetext =~ m|AUTHOR\s+=>\s+.Phineas\sT.\sBluster|,
    'Makefile.PL contains correct author');
ok($filetext =~ m|AUTHOR.*\(phineas\@anonymous\.com\)|,
    'Makefile.PL contains correct e-mail');
ok($filetext =~ m|ABSTRACT\s+=>\s+'Test\sof\sthe\scapacities\sof\sEU::MM'|,
    'Makefile.PL contains correct abstract');

six_file_tests(7, $testmod); # first arg is # entries in MANIFEST


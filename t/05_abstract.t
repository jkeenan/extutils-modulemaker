# t/05_abstract.t

use Test::More qw/no_plan/;
use strict;
use warnings;

BEGIN { use_ok('ExtUtils::ModuleMaker'); }
use lib ("./t/testlib");
use _Auxiliary qw( read_file_string read_file_array );

ok( chdir 'blib/testing' || chdir '../blib/testing', 
    "chdir 'blib/testing'" );

########################################################################

my $MOD;

ok( 
    $MOD = ExtUtils::ModuleMaker->new( {
        NAME           => 'Alpha::Beta',
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
    } ),
    "call ExtUtils::ModuleMaker->new for Alpha-Beta"
);

ok( $MOD->complete_build(), "call $MOD->complete_build" );

ok( chdir 'Alpha-Beta', "cd Alpha-Beta" );

for ( qw/LICENSE Makefile.PL MANIFEST README Todo/) {
    ok( -f, "file $_ exists" );
}
ok(! -f 'Changes', 'Changes file correctly not created');
for ( qw/lib scripts t/) {
    ok( -d, "directory $_ exists" );
}

my ($filetext, @filetext);
ok($filetext = read_file_string('Makefile.PL'),
    'Able to read Makefile.PL');
ok($filetext =~ m|AUTHOR\s+=>\s+.Phineas\sT.\sBluster|,
    'Makefile.PL contains correct author');
ok($filetext =~ m|AUTHOR.*\(phineas\@anonymous\.com\)|,
    'Makefile.PL contains correct e-mail');
ok($filetext =~ m|ABSTRACT\s+=>\s+'Test\sof\sthe\scapacities\sof\sEU::MM'|,
    'Makefile.PL contains correct abstract');

ok(@filetext = read_file_array('MANIFEST'),
    'Able to read MANIFEST');
ok(@filetext == 7,
    'Correct number of entries in MANIFEST');

ok(chdir 'lib/Alpha', 'Directory is now lib/alpha');
ok($filetext = read_file_string('Beta.pm'),
    'Able to read Beta.pm');
ok($filetext =~ m|Alpha::Beta\s-\sTest\sof\sthe\scapacities\sof\sEU::MM|,
    'POD contains module name and abstract');
ok($filetext =~ m|=head1\sHISTORY|,
    'POD contains history head');
ok($filetext =~ m|
        Phineas\sT\.\sBluster\n
        \s+CPAN\sID:\s+PTBLUSTER\n
        \s+Peanut\sGallery\n
        \s+phineas\@anonymous\.com\n
        \s+http:\/\/www\.anonymous\.com\/~phineas
        |xs,
    'POD contains correct author info');


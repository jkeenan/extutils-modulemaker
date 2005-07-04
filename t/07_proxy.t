# t/07_proxy.t
use strict;
use warnings;

use Test::More qw(no_plan);
BEGIN { 
    use_ok('ExtUtils::ModuleMaker'); 
    use_ok('Module::Build')
}
use lib ("./t/testlib");
use _Auxiliary qw( read_file_string read_file_array );

ok( chdir 'blib/testing' || chdir '../blib/testing', 
    "chdir 'blib/testing'" );

########################################################################

my $mod;
my $testmod = 'Delta';

ok( 
    $mod = ExtUtils::ModuleMaker->new( {
        NAME           => "Alpha::$testmod",
        ABSTRACT       => 'Test of the capacities of EU::MM',
        COMPACT        => 1,
        CHANGES_IN_POD => 1,
        BUILD_SYSTEM   => 'Module::Build and proxy Makefile.PL',
        AUTHOR         => {
           'NAME'         => 'Phineas T. Bluster',
           'CPANID'       => 'PTBLUSTER',
           'ORGANIZATION' => 'Peanut Gallery',
           'EMAIL'        => 'phineas@anonymous.com',
           'WEBSITE'      => 'http://www.anonymous.com/~phineas',
        },
    } ),
    "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
);

ok( $mod->complete_build(), 'call complete_build()' );

ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );

for ( qw/Build.PL LICENSE Makefile.PL MANIFEST README Todo/) {
    ok( -f, "file $_ exists" );
}
ok(! -f 'Changes', 'Changes file correctly not created');
for ( qw/lib scripts t/) {
    ok( -d, "directory $_ exists" );
}

my ($filetext, @filetext);
ok($filetext = read_file_string('Makefile.PL'),
    'Able to read Makefile.PL');
ok($filetext =~ m|Module::Build::Compat|,
    'Makefile.PL will call Module::Build or install it');

ok($filetext = read_file_string('Build.PL'),
    'Able to read Build.PL');

ok(@filetext = read_file_array('MANIFEST'),
    'Able to read MANIFEST');
ok(@filetext == 8,
    'Correct number of entries in MANIFEST');

ok(chdir 'lib/Alpha', 'Directory is now lib/Alpha');
ok($filetext = read_file_string("$testmod.pm"),
    "Able to read $testmod.pm");
ok($filetext =~ m|Alpha::$testmod\s-\sTest\sof\sthe\scapacities\sof\sEU::MM|,
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


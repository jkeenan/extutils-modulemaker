# t/07_proxy.t
use warnings;
use Test::More qw(no_plan);
BEGIN { 
    use_ok('ExtUtils::ModuleMaker'); 
    use_ok('Module::Build')
}
use strict;
use lib ("./t");
use Test::Readfile qw( read_file_string read_file_array );

ok( chdir 'blib/testing' || chdir '../blib/testing', 
    "chdir 'blib/testing'" );

########################################################################

my $MOD;

ok( 
    $MOD = ExtUtils::ModuleMaker->new( {
        NAME           => 'Alpha::Delta',
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
    "call ExtUtils::ModuleMaker->new for Alpha-Delta"
);

ok( $MOD->complete_build(), "call $MOD->complete_build" );

ok( chdir 'Alpha-Delta', "cd Alpha-Delta" );

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

ok(chdir 'lib/Alpha', 'Directory is now lib/alpha');
ok($filetext = read_file_string('Delta.pm'),
    'Able to read Delta.pm');
ok($filetext =~ m|Alpha::Delta\s-\sTest\sof\sthe\scapacities\sof\sEU::MM|,
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


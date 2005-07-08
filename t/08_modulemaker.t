# t/08_modulemaker.t
use strict;
local $^W = 1;
use Test::More 
# tests => 25;
qw(no_plan);

BEGIN { use_ok('ExtUtils::ModuleMaker'); }
BEGIN { use_ok( 'File::Temp', qw| tempdir |); }
BEGIN { use_ok( 'File::Copy'); }

use lib ("./t/testlib");
use _Auxiliary qw(
    read_file_string
    six_file_tests
);

my $tdir = tempdir( CLEANUP => 1);
ok(copy ("./scripts/modulemaker", $tdir), 
    "copied modulemaker for testing purposes");
ok(chdir $tdir, 'changed to temp directory for testing');
{
    local *IN; local *OUT; local $_;
    my $match = 'use ExtUtils::ModuleMaker;';
    ok((open IN, 'modulemaker'), "opened modulemaker for reading");
    ok((open OUT, ">modulemaker.a"), "opened modulemaker.a for writing");
    while (<IN>) {
        chomp;
        if ($_ eq $match) {
            print OUT "use blib;\n$match\n";
        } else {
            print OUT "$_\n";
        }
    }
    ok(close OUT, "closed modulemaker.a after writing");
    ok(close IN, "closed modulemaker after reading");
}

{
    local *IN;
    ok((open IN, 'modulemaker.a'), "opened modulemaker.a for reading");
    my @arr = <IN>;
    for (my $i=0; $i<=13; $i++) {
        print STDERR $arr[$i];
    }
    ok(close IN, "closed modulemaker.a after reading");
}

ok(unlink ("$tdir/modulemaker"), "deleted testing copy of modulemaker");
ok(unlink ("$tdir/modulemaker.a"), "deleted testing copy of modulemaker.a");


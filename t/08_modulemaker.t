# t/08_modulemaker.t
use strict;
local $^W = 1;
use Test::More 
# tests => 8;
qw(no_plan);

BEGIN { use_ok('ExtUtils::ModuleMaker'); }
BEGIN {
    use_ok( 'File::Temp', qw| tempdir |);
    use_ok( 'File::Copy' );
    use_ok( 'File::Find' );
    use_ok( 'Cwd' );
}

my $cwd = cwd();

# my $tdir = tempdir( CLEANUP => 1);
# ok(chdir $tdir, 'changed to temp directory for testing');

ok((mkdir 'tmp', 0755), "able to create testing directory");
ok(chdir 'tmp', 'changed to tmp directory for testing');

ok(! system("$^X -Mblib $cwd/blib/script/modulemaker -Icn XYZ::ABC"), 
    "able to call modulemaker utility");

ok(-d 'XYZ-ABC', "compact top directory created");
ok(-f "XYZ-ABC/$_", "$_ file created")
    for qw| Changes LICENSE MANIFEST Makefile.PL README Todo |;
ok(-d "XYZ-ABC/$_", "$_ directory created")
    for qw| lib t |;

ok(chdir $cwd, 'changed back to original directory after testing');

find {
    bydepth   => 1,
    no_chdir  => 1,
    wanted    => sub {
        if (! -l && -d _) {
            rmdir  or warn "Couldn't rmdir $_: $!";
        } else {
            unlink or warn "Couldn't unlink $_: $!";
        }
    }
} => 'tmp';
ok(! -d 'tmp', "tmp directory has been removed");

__END__

use lib ("./t/testlib");
use _Auxiliary qw(
    read_file_string
    six_file_tests
);
#    use_ok( 'IO::Capture::Stderr');
# my $capture = IO::Capture::Stderr->new();
# $capture->start();
# $capture->stop();
ok(copy ("./scripts/modulemaker", $tdir), 
    "copied modulemaker for testing purposes");
ok(chdir $tdir, 'changed to temp directory for testing');
{
    local *IN;
#    local *OUT;
#    local $_;
#    my $match = 'use ExtUtils::ModuleMaker;';
    ok((open IN, 'modulemaker'), "opened modulemaker for reading");
#    ok((open OUT, ">modulemaker.a"), "opened modulemaker.a for writing");
#    while (<IN>) {
#        chomp;
#        if ($_ eq $match) {
#            print OUT "use blib;\n$match\n";
#        } else {
#            print OUT "$_\n";
#        }
#    }
#    ok(close OUT, "closed modulemaker.a after writing");
    ok(close IN, "closed modulemaker after reading");
}

#{
#    local *IN;
#    ok((open IN, 'modulemaker.a'), "opened modulemaker.a for reading");
#    my @arr = <IN>;
#    for (my $i=0; $i<=13; $i++) {
#        print STDERR $arr[$i];
#    }
#    ok(close IN, "closed modulemaker.a after reading");
#}
#ok((chmod 0755, ('modulemaker.a')), "made modulemaker.a executable");
#system("$tdir/modulemaker.a -n ABC::XYZ");
#ok(unlink ("$tdir/modulemaker.a"), "deleted testing copy of modulemaker.a");

ok(unlink ("$tdir/modulemaker"), "deleted testing copy of modulemaker");


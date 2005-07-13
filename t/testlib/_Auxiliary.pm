package _Auxiliary;
# Contains test subroutines for distribution with ExtUtils::ModuleMaker
# As of:  July 4, 2005
use strict;
use warnings;
use vars qw| @ISA @EXPORT_OK |; 
require Exporter;
@ISA         = qw(Exporter);
@EXPORT_OK   = qw(
    read_file_string
    read_file_array
    six_file_tests
    rmtree
    setuptmpdir
    cleanuptmpdir
    check_MakefilePL 
); 
*ok = *Test::More::ok;
*is = *Test::More::is;
*like = *Test::More::like;
use File::Find;
use Cwd;

sub read_file_string {
    my $file = shift;
    open my $fh, $file or die "Unable to open filehandle: $!";
    my $filetext = do { local $/; <$fh> };
    close $fh or die "Unable to close filehandle: $!";
    return $filetext;
}

sub read_file_array {
    my $file = shift;
    open my $fh, $file or die "Unable to open filehandle: $!";
    my @filetext = <$fh>;
    close $fh or die "Unable to close filehandle: $!";
    return @filetext;
}

sub six_file_tests {
    my ($manifest_entries, $testmod) = @_;
    my @filetext = read_file_array('MANIFEST');
    is(scalar(@filetext), $manifest_entries,
        'Correct number of entries in MANIFEST');
    
    my $str;
    ok(chdir 'lib/Alpha', 'Directory is now lib/Alpha');
    ok($str = read_file_string("$testmod.pm"),
        "Able to read $testmod.pm");
    ok($str =~ m|Alpha::$testmod\s-\sTest\sof\sthe\scapacities\sof\sEU::MM|,
        'POD contains module name and abstract');
    ok($str =~ m|=head1\sHISTORY|,
        'POD contains history head');
    ok($str =~ m|
            Phineas\sT\.\sBluster\n
            \s+CPAN\sID:\s+PTBLUSTER\n
            \s+Peanut\sGallery\n
            \s+phineas\@anonymous\.com\n
            \s+http:\/\/www\.anonymous\.com\/~phineas
            |xs,
        'POD contains correct author info');
} 

sub rmtree {
    my $dir = shift;
    my %findargs = (
        bydepth   => 1,
        no_chdir  => 1,
        wanted    => sub {
            if (! -l && -d _) {
                rmdir  or warn "Couldn't rmdir $_: $!";
            } else {
                unlink or warn "Couldn't unlink $_: $!";
            }
        }
    );
    File::Find::find { %findargs } => $dir;
}

sub setuptmpdir {
    # Manually create 'tmp' directory for testing and move into it
    my $cwd = cwd();
    my $tmp = 'tmp';
    ok((mkdir $tmp, 0755), "able to create testing directory");
    ok(chdir $tmp, 'changed to tmp directory for testing');
    return ($cwd, $tmp);
}

sub cleanuptmpdir {
    # Cleanup 'tmp' directory following testing
    my ($cwd, $tmp) = @_;
    ok(chdir $cwd, 'changed back to original directory after testing');
    rmtree($tmp);
    ok(! -d $tmp, "tmp directory has been removed");
}

sub check_MakefilePL {
    my ($topdir, $predictref) = @_;
    my @pred = @$predictref;

    my $mkfl = "$topdir/Makefile.PL";
    local *MAK;
    open MAK, $mkfl or die "Unable to open Makefile.PL: $!";
    my $bigstr;
    {    local $/; $bigstr = <MAK>; }
    like($bigstr, qr/
            NAME.+($pred[0]).+
            VERSION_FROM.+($pred[1]).+
            AUTHOR.+($pred[2]).+
            ($pred[3]).+
            ABSTRACT.+($pred[4]).+
        /sx, "Makefile.PL has predicted values");
    close MAK;
}

1;


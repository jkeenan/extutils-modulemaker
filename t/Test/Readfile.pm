package Test::Readfile;
# Contains test subroutines for distribution with ExtUtils::ModuleMaker
# As of:  November 14, 2004
require Exporter;
our @ISA         = qw(Exporter);
our @EXPORT      = ();
our @EXPORT_OK   = qw( read_file_string read_file_array ); 

sub read_file_string {
    my $file = shift;
    open FH, $file;
    my $filetext = do { local $/; <FH> };
    close FH;
    return $filetext;
}

sub read_file_array {
    my $file = shift;
    open FH, $file;
    my @filetext = <FH>;
    close FH;
    return @filetext;
}

1;


package _Auxiliary;
# Contains test subroutines for distribution with ExtUtils::ModuleMaker
# As of:  July 4, 2005
require Exporter;
our @ISA         = qw(Exporter);
our @EXPORT_OK   = qw( read_file_string read_file_array ); 

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

1;


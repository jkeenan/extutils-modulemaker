package Defaults::Identify;
our $VERSION = 0.01;
use strict;
use warnings;
use Carp;

sub new {
    my $class = shift;
    my (%data, %files);
    if ($^O eq 'MSWin32') {
        require Win32;
        Win32->import( qw(CSIDL_LOCAL_APPDATA) );
        $data{realhome} =  Win32::GetFolderPath( CSIDL_LOCAL_APPDATA() );
        $data{realhome} =~ s|(.*?)\\Local Settings(.*)|$1$2|;
    } else {
        $data{realhome} = $ENV{HOME};
    }
    $data{personal_dir} = "$data{realhome}/.modulemaker"; 
    $data{personal_path} = "ExtUtils/ModuleMaker/Personal";
    $data{full_dir} = "$data{personal_dir}/$data{personal_path}";
    $data{personal_file} = "Defaults.pm";
    chdir $data{full_dir} or croak "Couldn't change to $data{full_dir}: $!";
    opendir my $dirh, $data{full_dir} 
        or croak "Couldn't open $data{full_dir} for reading: $!";
    while (defined (my $f = readdir $dirh) ) {
        next unless -f $f;
        next if $f =~ /(^\.|~$)/;
        $files{$f}++;
    }
    closedir $dirh or die "Couldn't close $data{full_dir} after reading: $!";
    $data{files} = { %files };
    my $self = bless ( { %data }, ref ($class) || $class);
    return $self;
}

sub print_all {
    my $self = shift;
    my %data = %$self;
    my %files = %{$data{files}};
    print "$_\n" for (sort keys %files);
}

sub confirm_defaults {
    my $self = shift;
    my %data = %$self;
    my %files = %{$data{files}};
    if (-f "$data{full_dir}/$data{personal_file}") {
        print "\n$data{full_dir}/$data{personal_file} correctly located\n\n";
    } else {
        print "\n$data{full_dir}/$data{personal_file} NOT correctly located\n\n";
    }
}

sub hide_defaults {
    my $self = shift;
    my %data = %$self;
    my %files = %{$data{files}};
    if ($files{$data{personal_file}}) {
        rename "$data{full_dir}/$data{personal_file}",
               "$data{full_dir}/$data{personal_file}.hidden",
                   or croak "Unable to rename file for hiding: $!";
    }
}

sub reveal_defaults {
    my $self = shift;
    my %data = %$self;
    my %files = %{$data{files}};
    if (-f "$data{full_dir}/$data{personal_file}.hidden") {
        rename "$data{full_dir}/$data{personal_file}.hidden",
               "$data{full_dir}/$data{personal_file}",
                   or croak "Unable to rename file for hiding: $!";
    }
}

sub show_default_values_more {
    my $self = shift;
    my %data = %$self;
    if (-f "$data{full_dir}/$data{personal_file}") {
#        system ("more $data{full_dir}/$data{personal_file}");
        open my $fh, "$data{full_dir}/$data{personal_file}"
            or croak "Unable to display default values file: $!";
        while (<$fh>) {
            print;
        }
    } else {
        croak "Unable to locate default values file: $!";
    }
}    

1;



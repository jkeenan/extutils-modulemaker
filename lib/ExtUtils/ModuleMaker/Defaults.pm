package ExtUtils::ModuleMaker::Defaults;
# as of 08/20/2005
use strict;
local $^W = 1;
use Carp;

my $usage = <<ENDOFUSAGE;

There were problems with your data supplied to ExtUtils::ModuleMaker.
Please fix the problems listed above and try again.

ENDOFUSAGE

my %default_values = (
        LICENSE         => 'perl',
        VERSION         => 0.01,
        ABSTRACT        => 'Module abstract (<= 44 characters) goes here',
        AUTHOR          => 'A. U. Thor',
        CPANID          => 'MODAUTHOR',
        ORGANIZATION    => 'XYZ Corp.',
        WEBSITE         => 'http://a.galaxy.far.far.away/modules',
        EMAIL           => 'a.u.thor@a.galaxy.far.far.away',
        BUILD_SYSTEM    => 'ExtUtils::MakeMaker',
        COMPACT         => 0,
        VERBOSE         => 0,
        INTERACTIVE     => 0,
        NEED_POD        => 1,
        NEED_NEW_METHOD => 1,
        CHANGES_IN_POD  => 0,
        PERMISSIONS     => 0755,
        USAGE_MESSAGE   => $usage,
);

my $personal_defaults_file = "$ENV{HOME}/.modulemakerrc";

if (-f $personal_defaults_file) {
    $default_values{PERSONAL_DEFAULTS} = $personal_defaults_file;
}  

sub default_values {
    my $self = shift;
    return { %default_values };
}

sub _personal_defaults_checker {
    my $self = shift;
    my $personal_ref = shift;
    my $defaults_location = shift;
    if ($defaults_location) {
        croak "No personal defaults file at $defaults_location: $!" 
            unless -f $defaults_location;
        require $defaults_location;  # I'm suspicious of this
        foreach my $def ( keys %{$personal_ref} ) {
            if ($def eq 'NAME' or $def eq 'ABSTRACT') {
                warn "Module $def cannot be saved in personal default file;\n"
                . "  Must be provided anew each time: $!";
            } else {
                $self->{$def} = $personal_ref->{$def};
            }
        }
    }
}

1;

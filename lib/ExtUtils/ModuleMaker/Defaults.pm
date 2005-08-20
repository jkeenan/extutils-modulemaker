package ExtUtils::ModuleMaker::Defaults;
# as of 08/20/2005
use strict;
local $^W = 1;

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

sub default_values {
    my $self = shift;
    return { %default_values };
}

1;

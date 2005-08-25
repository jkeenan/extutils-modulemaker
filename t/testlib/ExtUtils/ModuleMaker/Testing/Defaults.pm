package ExtUtils::ModuleMaker::Testing::Defaults;
# as of 08/24/2005
use strict;
local $^W = 1;

my $usage = <<ENDOFUSAGE;

There were problems with your data supplied to ExtUtils::ModuleMaker.
Please fix the problems listed above and try again.

ENDOFUSAGE

my %default_values = (
        NAME            => 'EU::MM::Testing::Defaults',
        LICENSE         => 'perl',
        VERSION         => 0.01,
        ABSTRACT        => 'Module abstract (<= 44 characters) goes here',
        AUTHOR          => 'Hilton Stallone',
        CPANID          => 'RAMBO',
        ORGANIZATION    => 'Parliamentary Pictures',
        WEBSITE         => 'http://parliamentarypictures.com',
        EMAIL           => 'hiltons@parliamentarypictures.com',
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


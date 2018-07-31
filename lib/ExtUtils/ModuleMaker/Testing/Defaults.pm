package ExtUtils::ModuleMaker::Testing::Defaults;
use strict;
use warnings;
our $VERSION = "0.65";

my $usage = <<ENDOFUSAGE;

There were problems with your data supplied to ExtUtils::ModuleMaker.
Please fix the problems listed above and try again.

ENDOFUSAGE

sub get_usage_as_string { return $usage; }

my @default_values = (
        NAME             => q{EU::MM::Testing::Defaults},
        LICENSE          => q{perl},
        VERSION          => 0.01,
        ABSTRACT         => q{Module abstract (<= 44 characters) goes here},
        AUTHOR           => q{Hilton Stallone},
        CPANID           => q{RAMBO},
        ORGANIZATION     => q{Parliamentary Pictures},
        WEBSITE          => q{http://parliamentarypictures.com},
        EMAIL            => q{hiltons@parliamentarypictures.com},
        BUILD_SYSTEM     => q{ExtUtils::MakeMaker},
        COMPACT          => 0,
        VERBOSE          => 0,
        INTERACTIVE      => 0,
        NEED_POD         => 1,
        NEED_NEW_METHOD  => 1,
        CHANGES_IN_POD   => 0,
        PERMISSIONS      => 0755,
        SAVE_AS_DEFAULTS => 0,
        USAGE_MESSAGE    => $usage,
        FIRST_TEST_NUMBER                   => 1,
        TEST_NUMBER_FORMAT                  => "%03d",
        TEST_NAME                           => 'load',
        EXTRA_MODULES_SINGLE_TEST_FILE      => 0,
        TEST_NAME_DERIVED_FROM_MODULE_NAME  => 0,
        TEST_NAME_SEPARATOR                 => q{_},
        INCLUDE_MANIFEST_SKIP               => 0,
        INCLUDE_TODO                        => 1,
        INCLUDE_POD_COVERAGE_TEST           => 0,
        INCLUDE_POD_TEST                    => 0,
        INCLUDE_LICENSE                     => 1,
        INCLUDE_SCRIPTS_DIRECTORY           => 1,
        INCLUDE_FILE_IN_PM                  => 0,
);

my %default_values = @default_values;

sub default_values {
    my $self = shift;
    return { %default_values };
}

sub get_default_values_as_string {
    my $str = '';
    for (my $i=0; $i<=$#default_values; $i += 2) {
        my $j = $i + 1;
        $str .= sprintf("    %-36s  => '%s',\n" => ($default_values[$i], $default_values[$j]));
    }
    return $str;
}

1;


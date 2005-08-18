package ExtUtils::ModuleMaker::Defaults;
# as of 08/16/2005
use strict;
local $^W = 1;

#use vars qw ( @ISA @EXPORT_OK );
#require Exporter;
#@ISA = ('Exporter');
#@EXPORT_OK = qw( default_values );


my $usage = <<ENDOFUSAGE;

There were problems with your data supplied to ExtUtils::ModuleMaker.
Please fix the problems listed above and try again.

ENDOFUSAGE

sub default_values {
#    my %default_values = (
    my $self = shift;
    return {
        LICENSE  => 'perl',
        VERSION  => 0.01,
        ABSTRACT => 'Module abstract (<= 44 characters) goes here',
        AUTHOR   => {
            NAME         => 'A. U. Thor',
            CPANID       => 'AUTHOR',
            ORGANIZATION => 'XYZ Corp.',
            WEBSITE      => 'http://a.galaxy.far.far.away/modules',
            EMAIL        => 'a.u.thor@a.galaxy.far.far.away',
        },
        BUILD_SYSTEM    => 'ExtUtils::MakeMaker',
        COMPACT         => 0,
        VERBOSE         => 0,
        INTERACTIVE     => 0,
        NEED_POD        => 1,
        NEED_NEW_METHOD => 1,
        CHANGES_IN_POD  => 0,

        PERMISSIONS => 0755,
        USAGE_MESSAGE => $usage,
#     );
#     return { %default_values };
    }
}

1;



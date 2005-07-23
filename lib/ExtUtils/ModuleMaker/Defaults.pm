package ExtUtils::ModuleMaker::Defaults;
use strict;
local $^W = 1;

use vars qw ( @ISA @EXPORT_OK );
require Exporter;
@ISA = ('Exporter');
@EXPORT_OK = qw( default_values standard_text );

my $USAGE = <<ENDOFUSAGE;

There were problems with your data supplied to ExtUtils::ModuleMaker.
Please fix the problems listed above and try again.

ENDOFUSAGE

sub default_values {
    my %default_values = (
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
        USAGE_MESSAGE => $USAGE,
    );
    return { %default_values };
}

#######################################

my %pod_wrapper = (
    head => '

#################### main pod documentation begin ###################
## Below is the stub of documentation for your module. 
## You better edit it!

',
    tail => '

 ====cut

#################### main pod documentation end ###################

',
);

my $block_new_method = <<'EOFBLOCK';

sub new
{
    my ($class, %parameters) = @_;

    my $self = bless ({}, ref ($class) || $class);

    return $self;
}

EOFBLOCK

my $description = <<EOFBLOCK;
Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.
EOFBLOCK

my $subroutine_header = <<EOFBLOCK;

#################### subroutine header begin ####################

 ====head2 sample_function

 Usage     : How to use this function/method
 Purpose   : What it does
 Returns   : What it returns
 Argument  : What it wants to know
 Throws    : Exceptions and other anomolies
 Comments  : This is a sample subroutine header.
           : It is polite to include more pod and fewer comments.

See Also   : 

 ====cut

#################### subroutine header end ####################

EOFBLOCK

my $block_final_one = <<EOFBLOCK;

1;
# The preceding line will help the module return a true value

EOFBLOCK

sub standard_text {
    my %standard_text = (
        pod_wrapper => \%pod_wrapper,
	block_new_method => $block_new_method,
	block_module_header_description => $description,
	subroutine_header => $subroutine_header,
	block_final_one => $block_final_one,
    );
    return { %standard_text };
}

1;


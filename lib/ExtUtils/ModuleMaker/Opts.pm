package ExtUtils::ModuleMaker::Opts;
# as of 09-16-2005
use strict;
local $^W = 1;
# use base qw(Exporter);
# use vars qw( @EXPORT_OK $VERSION );
use vars qw( $VERSION );
$VERSION = '0.39_12';
#@EXPORT_OK   = qw(
#    get_standard_options
#);
use Getopt::Std;
use Carp;


my %opts;
getopts( "bhqsCIPVcn:a:v:l:u:p:o:w:e:t:r:d:", \%opts );
croak Usage() if ( $opts{h} );

my %standard_options = (
    ( ( $opts{c} ) ? ( COMPACT               => $opts{c} ) : () ),
    ( ( $opts{V} ) ? ( VERBOSE               => $opts{V} ) : () ),
    ( ( $opts{C} ) ? ( CHANGES_IN_POD        => $opts{C} ) : () ),
    ( ( $opts{P} ) ? ( NEED_POD              => 0        ) : () ),
    ( ( $opts{q} ) ? ( NEED_NEW_METHOD       => 0        ) : () ),
#    ( ( $opts{I} ) ? ( INTERACTIVE           => 0        ) : 1  ),
    INTERACTIVE      => ( ( $opts{I} ) ? 0 : 1 ),
    ( ( $opts{s} ) ? ( SAVE_AS_DEFAULTS      => $opts{s} ) : () ),
    
    ( ( $opts{n} ) ? ( NAME                  => $opts{n} ) : () ),
    ( ( $opts{a} ) ? ( ABSTRACT              => $opts{a} ) : () ),
    ( ( $opts{b} ) ? ( BUILD_SYSTEM          => $opts{b} ) : () ),
    ( ( $opts{v} ) ? ( VERSION               => $opts{v} ) : () ),
    ( ( $opts{l} ) ? ( LICENSE               => $opts{l} ) : () ),
    ( ( $opts{u} ) ? ( AUTHOR                => $opts{u} ) : () ),
    ( ( $opts{p} ) ? ( CPANID                => $opts{p} ) : () ),
    ( ( $opts{o} ) ? ( ORGANIZATION          => $opts{o} ) : () ),
    ( ( $opts{w} ) ? ( WEBSITE               => $opts{w} ) : () ),
    ( ( $opts{e} ) ? ( EMAIL                 => $opts{e} ) : () ),
    ( ( $opts{r} ) ? ( PERMISSIONS           => $opts{r} ) : () ),
    ( ( $opts{d} ) ? ( ALT_BUILD             => $opts{d} ) : () ),
    USAGE_MESSAGE => Usage(),
);

sub new {
    my $class = shift;
    my $eumm  = shift;
    my $self = bless( {}, $class );
    return $self;
}

sub get_standard_options {
    my $self = shift;
    require $self;

    return %standard_options;
}

sub Usage {
    my $message = <<ENDOFUSAGE;
modulemaker [-CIPVch] [-v version] [-n module_name] [-a abstract]
        [-u author_name] [-p author_CPAN_ID] [-o organization]
        [-w author_website] [-e author_e-mail]
        [-l license_name] [-b build_system] [-s save_selections_as_defaults ]

Currently Supported Features
    -a   Specify (in quotes) an abstract for this extension
    -b   Specify a build system for this extension
    -c   Flag for compact base directory name
    -C   Omit creating the Changes file, add HISTORY heading to stub POD
    -d   Call methods which override default methods from this module
    -e   Specify author's e-mail address
    -h   Display this help message
    -I   Disable INTERACTIVE mode, the command line arguments better be complete
    -l   Specify a license for this extension
    -n   Specify a name to use for the extension (required)
    -o   Specify (in quotes) author's organization
    -p   Specify author's CPAN ID
    -P   Omit the stub POD section
    -q   Flag to omit a constructor from module
    -r   Specify permissions
    -s   Flag to save selections as new personal default values
    -u   Specify (in quotes) author's name
    -v   Specify a version number for this extension
    -V   Flag for verbose messages during module creation
    -w   Specify author's web site

modulemaker version: $VERSION
ExtUtils::ModuleMaker version: $ExtUtils::ModuleMaker::VERSION
ENDOFUSAGE

    return ($message);
}
#'
__END__

my $opt = ExtUtils::ModuleMaker::Opts->new(q{ExtUtils::ModuleMaker});
my %standard_options = $opt->get_standard_options();
my $mod = ExtUtils::ModuleMaker::Interactive->new( %standard_options);

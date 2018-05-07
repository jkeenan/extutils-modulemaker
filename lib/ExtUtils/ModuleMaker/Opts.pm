package ExtUtils::ModuleMaker::Opts;
use strict;
use warnings;
our $VERSION = "0.60";
use Getopt::Long;
use Carp;

sub new {
    my $class = shift;
    my $eumm_package  = shift;
    my $eumm_script   = shift;

    my $data = {};
    $data->{NAME} = $class;
    {
        eval "require $eumm_package";
        no strict 'refs';
        $data->{VERSION} = ${$eumm_package . "::VERSION"};
    }
    $data->{PACKAGE} = $eumm_package;
    $data->{SCRIPT} = $eumm_script;

    Getopt::Long::Configure("bundling");
    my %opts;

    GetOptions(
        # flags indicating on/off
        "build_system|build-system|b"           => \$opts{b},
        "compact|c"                             => \$opts{c},
        "changes_in_pod|changes-in-pod|C"       => \$opts{C},
        "help|h"                                => \$opts{h},
        "no_interactive|no-interactive|I"       => \$opts{I},
        "no_pod|no-pod|P"                       => \$opts{P},
        "no_new_method|no-new-method|q"         => \$opts{q},
        "save_as_defaults|save-as-defaults|s"   => \$opts{s},
        "verbose|V"                             => \$opts{V},

        # take string
        # adenlopruvw
        "abstract|a=s"                          => \$opts{a},
        "alt_build|alt-build|d=s"               => \$opts{d},
        "email|e=s"                             => \$opts{e},
        "name|n=s"                              => \$opts{n},
        "license|l=s"                           => \$opts{l},
        "organization|o=s"                      => \$opts{o},
        "cpanid|p=s"                            => \$opts{p},
        "permissions|r=s"                       => \$opts{r},
        "author|u=s"                            => \$opts{u},
        "version|v=s"                           => \$opts{v},
        "website|w=s"                           => \$opts{w},

    ) or croak("Error in command line arguments\n");
    if ($opts{h}) {
        print Usage($eumm_script, $eumm_package);
        return;
    }

    my %standard_options = (
        # bcCIPqsV
        ( ( $opts{b} ) ? ( BUILD_SYSTEM          => 'Module::Build' ) : () ),
        ( ( $opts{c} ) ? ( COMPACT               => $opts{c} ) : () ),
        ( ( $opts{C} ) ? ( CHANGES_IN_POD        => $opts{C} ) : () ),
        INTERACTIVE      => ( ( $opts{I} ) ? 0 : 1 ),
        ( ( $opts{P} ) ? ( NEED_POD              => 0        ) : () ),
        ( ( $opts{q} ) ? ( NEED_NEW_METHOD       => 0        ) : () ),
        ( ( $opts{s} ) ? ( SAVE_AS_DEFAULTS      => $opts{s} ) : () ),
        ( ( $opts{V} ) ? ( VERBOSE               => $opts{V} ) : () ),

        # adenlopruvw
        ( ( $opts{a} ) ? ( ABSTRACT              => $opts{a} ) : () ),
        ( ( $opts{d} ) ? ( ALT_BUILD             => $opts{d} ) : () ),
        ( ( $opts{e} ) ? ( EMAIL                 => $opts{e} ) : () ),
        ( ( $opts{n} ) ? ( NAME                  => $opts{n} ) : () ),
        ( ( $opts{l} ) ? ( LICENSE               => $opts{l} ) : () ),
        ( ( $opts{o} ) ? ( ORGANIZATION          => $opts{o} ) : () ),
        ( ( $opts{p} ) ? ( CPANID                => $opts{p} ) : () ),
        ( ( $opts{r} ) ? ( PERMISSIONS           => $opts{r} ) : () ),
        ( ( $opts{u} ) ? ( AUTHOR                => $opts{u} ) : () ),
        ( ( $opts{v} ) ? ( VERSION               => $opts{v} ) : () ),
        ( ( $opts{w} ) ? ( WEBSITE               => $opts{w} ) : () ),

        USAGE_MESSAGE => Usage(
            $data->{SCRIPT},
            $data->{PACKAGE},
            $data->{VERSION},
        ),
    );

    $data->{STANDARD_OPTIONS} = { %standard_options };

    return bless $data, $class;
}


sub get_standard_options {
    my $self = shift;
    return %{ $self->{STANDARD_OPTIONS} };
}

sub Usage {
    my ($script, $eumm_package) = @_;
    my $message = <<ENDOFUSAGE;
modulemaker [-CIPVbch] [-n module_name] [-a abstract]
        [-u author_name] [-p author_CPAN_ID] [-o organization]
        [-w author_website] [-e author_e-mail]
        [-l license_name] [-v version] [-s save_selections_as_defaults ]

Currently Supported Features
    -a|--abstract           Specify (in quotes) an abstract for this extension
    -b|--build_system       Use Module::Build as build system for this extension
    -c|--compact            Flag for compact base directory name
    -C|--changes_in_pod     Omit creating the Changes file, add HISTORY heading to stub POD
    -d|--alt_build          Call methods which override default methods from this module
    -e|--email              Specify author's e-mail address
    -h|--help               Display this help message and exit
    -I|--no_interactive     Disable INTERACTIVE mode, the command line arguments better be complete
    -l|--license            Specify a license for this extension
    -n|--name               Specify a name to use for the extension (required)
    -o|--organization       Specify (in quotes) author's organization
    -p|--cpanid             Specify author's CPAN ID
    -P|--no_pod             Flag to omit the stub POD section from module
    -q|--no_new_method      Flag to omit a constructor from module
    -r|--permissions        Specify permissions
    -s|--save_as_defaults   Flag to save selections as new personal default values
    -u|--author             Specify (in quotes) author's name
    -v|--version            Specify an initial version number for this extension
    -V|--verbose            Flag for verbose messages during module creation
    -w|--website            Specify author's web site

$script
$eumm_package version: $VERSION
ENDOFUSAGE

    return ($message);
}

1;

################### DOCUMENTATION ###################

=head1 NAME

ExtUtils::ModuleMaker::Opts - Process command-line options for F<modulemaker>

=head1 SYNOPSIS

    use ExtUtils::ModuleMaker::Opts;

    $eumm_package = q{ExtUtils::ModuleMaker};
    $eumm_script  = q{modulemaker};

    $opt = ExtUtils::ModuleMaker::Opts->new(
        $eumm_package,
        $eumm_script,
    );

    $mod = ExtUtils::ModuleMaker::Interactive->new(
        $opt->get_standard_options()
    );

=head1 DESCRIPTION

The methods in this package provide processing of command-line options for
F<modulemaker>, the command-line utility associated with Perl extension
ExtUtils::ModuleMaker, and for similar utilities associated with Perl
extensions which subclass ExtUtils::ModuleMaker.

=head1 METHODS

=head2 C<new()>

  Usage     : $opt = ExtUtils::ModuleMaker::Opts->new($package,$script) from
              inside a command-line utility such as modulemaker
  Purpose   : Creates an ExtUtils::ModuleMaker::Opts object
  Returns   : An ExtUtils::ModuleMaker::Opts object
  Argument  : Two arguments:
              1. String holding 'ExtUtils::ModuleMaker' or a package
              subclassed therefrom, e.g., 'ExtUtils::ModuleMaker::PBP'.
              2. String holding 'modulemaker' or the name of a command-line
                 utility similar to 'modulemaker' and found in the
                 'scripts/' directory of the distribution named in
                 argument 1

=head2 C<get_standard_options()>

  Usage     : %standard_options = $opt->get_standard_options from
              inside a command-line utility such as modulemaker
  Purpose   : Provide arguments to ExtUtils::ModuleMaker::Interactive::new()
              or to the constructor of the 'Interactive' package of a
              distribution subclassing ExtUtils::ModuleMaker
  Returns   : A hash suitable for passing to
              ExtUtils::ModuleMaker::Interactive::new() or similar constructor
  Argument  : n/a

=head1 SEE ALSO

F<ExtUtils::ModuleMaker>, F<modulemaker>,
F<ExtUtils::ModuleMaker::Interactive>, F<ExtUtils::ModuleMaker::PBP>,
F<mmkrpbp>.

=cut


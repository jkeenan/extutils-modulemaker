package ExtUtils::ModuleMaker::StandardText;
use strict;
local $^W = 1;

my %README_text = (
    eumm_instructions => q~
perl Makefile.PL
make
make test
make install
~,
    mb_instructions => q~
perl Build.PL
./Build
./Build test
./Build install
~,
    readme_top => q~

If this is still here it means the programmer was too lazy to create the readme file.

You can create it now by using the command shown above from this directory.

At the very least you should be able to use this set of instructions
to install the module...

~,
    readme_bottom => q~

If you are on a windows box you should use 'nmake' rather than 'make'.
~,
);

# Usage     : $self->file_text_README within complete_build()
# Purpose   : Build a supporting file
# Returns   : Text of the file being built
# Argument  : n/a
# Throws    : n/a
# Comments  : This method is a likely candidate for alteration in a subclass
sub file_text_README {
    my $self = shift;

    my $build_instructions =
        ( $self->{BUILD_SYSTEM} eq 'ExtUtils::MakeMaker' )
            ? $README_text{eumm_instructions}
            : $README_text{mb_instructions};
    return "pod2text $self->{NAME}.pm > README\n" . 
        $README_text{readme_top} .
	$build_instructions .
        $README_text{readme_bottom};
}

my $Makefile_text = q~

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => '%s',
    VERSION_FROM => '%s', # finds \$VERSION
    AUTHOR       => '%s (%s)',
    ABSTRACT     => '%s',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
                    },
);
~;

# Usage     : $self->file_text_Makefile 
# Purpose   : Build a supporting file
# Returns   : Text of the file being built
# Argument  : n/a
# Throws    : n/a
# Comments  : This method is a likely candidate for alteration in a subclass
sub file_text_Makefile {
    my $self = shift;
#    my $page = sprintf $self->{standard}{Makefile_text},
    my $page = sprintf $Makefile_text,
        map { my $s = $_; $s =~ s{'}{\\'}g; $s; }
    $self->{NAME},
    $self->{FILE},
    $self->{AUTHOR}{NAME},
    $self->{AUTHOR}{EMAIL},
    $self->{ABSTRACT};
    return $page;
}

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

sub pod_wrapper {
    my ( $self, $section ) = @_;
    my ($head, $tail);
    $head = $pod_wrapper{head};
    $tail = $pod_wrapper{tail};
    $tail =~ s/\n ====/\n=/g;
    return join( '', $head, $section, $tail );
}

my $block_new_method = <<'EOFBLOCK';

sub new
{
    my ($class, %parameters) = @_;

    my $self = bless ({}, ref ($class) || $class);

    return $self;
}

EOFBLOCK

# Usage     : $self->block_new_method() within generate_pm_file()
# Purpose   : Build part of a module pm file
# Returns   : Part of the file being built
# Argument  : $module: pointer to the module being built, for the primary
#                      module it is a pointer to $self
# Throws    : n/a
# Comments  : This method is a likely candidate for alteration in a subclass
sub block_new_method {
    my $self = shift;
    $block_new_method;
}

my $block_module_header_description = <<EOFBLOCK;
Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.
EOFBLOCK

# Usage     : $self->block_module_header ()
# Purpose   : Build part of a module pm file
# Returns   : Part of the file being built
# Argument  : $module: pointer to the module being built, for the primary
#                      module it is a pointer to $self
# Throws    : n/a
# Comments  : This method is a likely candidate for alteration in a subclass
sub block_module_header {
    my ( $self, $module ) = @_;

    my $description = $block_module_header_description;
    my $string = join(
        '',
        $self->pod_section(
            NAME => $self->module_value( $module, 'NAME' ) . ' - '
              . $self->module_value( $module, 'ABSTRACT' )
        ),
        $self->pod_section(
                SYNOPSIS => '  use '
              . $self->module_value( $module, 'NAME' )
              . "\n  blah blah blah\n"
        ),
        $self->pod_section( DESCRIPTION => $description ),
        $self->pod_section( USAGE       => '' ),
        $self->pod_section( BUGS        => '' ),
        $self->pod_section( SUPPORT     => '' ),
        (
            ( $self->{CHANGES_IN_POD} )
            ? $self->pod_section(
                HISTORY => $self->file_text_Changes('only pod')
              )
            : ()
        ),
        $self->pod_section(
            AUTHOR => $self->module_value( $module, 'AUTHOR', 'COMPOSITE' )
        ),
        $self->pod_section(
            COPYRIGHT =>
              $self->module_value( $module, 'LicenseParts', 'COPYRIGHT' )
        ),
        $self->pod_section( 'SEE ALSO' => 'perl(1).' ),
    );

    return $self->pod_wrapper($string);
}

sub pod_section {
    my ( $self, $heading, $content ) = @_;

    my $string = <<ENDOFSTUFF;

 ====head1 $heading

$content
ENDOFSTUFF

    $string =~ s/\n ====/\n=/g;
    return $string;
}

sub module_value {
    my ( $self, $module, @keys ) = @_;

    if ( scalar(@keys) == 1 ) {
        return ( $module->{ $keys[0] } )
          if ( exists( ( $module->{ $keys[0] } ) ) );
        return ( $self->{ $keys[0] } );
    }
    else { # only alternative currently possible is @keys == 2
        return ( $module->{ $keys[0] }{ $keys[1] } )
          if ( exists( ( $module->{ $keys[0] }{ $keys[1] } ) ) );
        return ( $self->{ $keys[0] }{ $keys[1] } );
    }
}

# Usage     : $self->file_text_Changes within block_module_header()
# Purpose   : Build a supporting file
# Returns   : Text of the file being built
# Argument  : $only_in_pod:  True value to get only a HISTORY section for POD
#                            False value to get whole Changes file
# Throws    : n/a
# Comments  : This method is a likely candidate for alteration in a subclass
sub file_text_Changes {
    my ( $self, $only_in_pod ) = @_;

    my $page;

    unless ($only_in_pod) {
        $page = <<EOF;
Revision history for Perl module $self->{NAME}

$self->{VERSION} $self->{timestamp}
    - original version; created by ExtUtils::ModuleMaker $self->{eumm_version}


EOF
    }
    else {
        $page = <<EOF;
$self->{VERSION} $self->{timestamp}
    - original version; created by ExtUtils::ModuleMaker $self->{eumm_version}
EOF
    }

    return $page;
}


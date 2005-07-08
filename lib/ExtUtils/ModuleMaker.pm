package ExtUtils::ModuleMaker;
use strict;
local $^W = 1;
use vars qw ($VERSION);
$VERSION = 0.33;

use ExtUtils::ModuleMaker::Licenses::Standard;
use ExtUtils::ModuleMaker::Licenses::Local;
use File::Path;

#################### PUBLICLY CALLABLE METHODS ####################

#!#!#!#!#
##   2 ##
sub new {
#    my ( $class, $paramsref ) = @_;
#    my %parameters = %{$paramsref};
    my ( $class, %parameters ) = @_;
    my $self = bless( default_values(), ref($class) || $class );
    foreach my $param ( keys %parameters ) {
        if ( ref( $parameters{$param} ) eq 'HASH' ) {
            foreach ( keys( %{ $parameters{$param} } ) ) {
                $self->{$param}{$_} = $parameters{$param}{$_};
            }
        }
        else {
            $self->{$param} = $parameters{$param};
        }
    }

    $self->set_author_data();
    $self->set_dates();
    $self->initialize_license();

    $self->{MANIFEST} = ['MANIFEST'];
    return ($self);
}

#!#!#!#!#
##   7 ##
sub complete_build {
    my $self = shift;

    $self->verify_values();

    $self->create_base_directory();
    $self->check_dir( map { "$self->{Base_Dir}/$_" } qw (lib t scripts) );

    $self->print_file( 'LICENSE', $self->{LicenseParts}{LICENSETEXT} );
    $self->print_file( 'README',  $self->file_text_README() );
    $self->print_file( 'Todo',    $self->file_text_ToDo() );

    unless ( $self->{CHANGES_IN_POD} ) {
        $self->print_file( 'Changes', $self->file_text_Changes() );
    }

    my $ct = 1;
    foreach my $module ( $self, @{ $self->{EXTRA_MODULES} } ) {
        $self->generate_pm_file($module);
        my $testfile = sprintf( "t/%03d_load.t", $ct );
        $self->print_file( $testfile,
            $self->file_text_test( $testfile, $module ) );
        $ct++;
    }

    #Makefile must be created after generate_pm_file which sets $self->{FILE}
    if ( $self->{BUILD_SYSTEM} eq 'ExtUtils::MakeMaker' ) {
        $self->print_file( 'Makefile.PL', $self->file_text_Makefile() );
    }
    else {
        $self->print_file( 'Build.PL', $self->file_text_Buildfile() );
        if ( $self->{BUILD_SYSTEM} eq 'Module::Build and proxy Makefile.PL' ) {
            $self->print_file( 'Makefile.PL',
                $self->file_text_proxy_makefile() );
        }
    }

    $self->print_file( 'MANIFEST', join( "\n", @{ $self->{MANIFEST} } ) );
    return 1;
}

#################### INTERNAL SUBROUTINES ####################

#!#!#!#!#
##   4 ##
# Usage     : $self->default_values() inside new()
# Purpose   : Defaults for new()
# Returns   : A reference to a hash of defaults as the basis for 'new'.
# Argument  : n/a
# Throws    : n/a
# Comments  : Geoff probably put this into a subroutine so it would be 
#             subclassable.  I'm leaving it here so that the defaults
#             are encapsulated within a subroutine rather than creating
#             a file-scoped lexical. 
sub default_values {
    my %defaults = (
        NAME     => 'None yet',
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
    );

    $defaults{USAGE_MESSAGE} = <<ENDOFUSAGE;

There were problems with your data supplied to ExtUtils::ModuleMaker.
Please fix the problems listed above and try again.

ENDOFUSAGE

    return ( \%defaults );
}

#!#!#!#!#
##   6 ##
# Usage     : $self->verify_values() within complete_build()
# Purpose   : Verify module values are valid and complete.
# Returns   : Error message if there is a problem
# Argument  : n/a
# Throws    : Will die with a death_message if errors and not interactive.
# Comments  : 
sub verify_values {
    my ($self) = @_;
    my @errors;

    push( @errors, 'NAME is required' )
      unless ( $self->{NAME} );
    push( @errors, 'ABSTRACTs are limited to 44 characters' )
      if ( length( $self->{ABSTRACT} ) > 44 );
    push( @errors, 'CPAN IDs are 3-9 characters' )
      if ( ( exists( $self->{AUTHOR}{CPANID} ) )
        && ( $self->{AUTHOR}{CPANID} !~ m/^\w{3,9}$/ ) );
    push( @errors, 'EMAIL addresses need to have an at sign' )
      if ( $self->{AUTHOR}{EMAIL} !~ m/.*\@.*/ );
    push( @errors, 'WEBSITEs should start with an "http:" or "https:"' )
      if ( $self->{AUTHOR}{WEBSITE} !~ m/https?:\/\/.*/ );
    push( @errors, 'LICENSE is not recognized"' )
      unless ( Verify_Local_License( $self->{LICENSE} )
        || Verify_Standard_License( $self->{LICENSE} ) );

    return () unless (@errors);
    $self->death_message(@errors);
}

#!#!#!#!#
##   8 ##
sub generate_pm_file {
    my ( $self, $module ) = @_;

    $self->create_pm_basics($module);

    my $page = $self->block_begin($module) .

      (
        ( $self->module_value( $module, 'NEED_POD' ) )
        ? $self->block_module_header($module)
        : ()
      )
      .

      (
        (
                 ( $self->module_value( $module, 'NEED_POD' ) )
              && ( $self->module_value( $module, 'NEED_NEW_METHOD' ) )
        )
        ? $self->block_subroutine_header($module)
        : ()
      )
      .

      (
        ( $self->module_value( $module, 'NEED_NEW_METHOD' ) )
        ? $self->block_new_method($module)
        : ()
      )
      .

      $self->block_final_one($module);

    $self->print_file( $module->{FILE}, $page );
}

#!#!#!#!#
##  10 ##
sub set_dates {
    my $self = shift;
    $self->{year}      = (localtime)[5] + 1900;
    $self->{timestamp} = scalar localtime;
    $self->{COPYRIGHT_YEAR} ||= $self->{year};
}

#!#!#!#!#
##  11 ##
sub set_author_data {
    my ($self) = @_;

    my $p_author = $self->{AUTHOR};
    $p_author->{COMPOSITE} = (
        "\t"
         . join( "\n\t",
            $p_author->{NAME},
            ( $p_author->{CPANID} ) ? "CPAN ID: $p_author->{CPANID}" : (),
            ( $p_author->{ORGANIZATION} ) ? "$p_author->{ORGANIZATION}" : (),
            $p_author->{EMAIL}, $p_author->{WEBSITE}, ),
    );
}

#!#!#!#!#
##  13 ##
# Usage     : 
# Purpose   : Create the directory where all the files will be created.
# Returns    $DIR = directory name where the files will live
# Argument   $package_name = name of module separated by '::'
# Throws    : 
# Comments  : see also:  check_dir()
sub create_base_directory {
    my $self = shift;

    $self->{Base_Dir} =
      join( ( $self->{COMPACT} ) ? '-' : '/', split( /::|'/, $self->{NAME} ) );
    $self->check_dir( $self->{Base_Dir} );
}

#!#!#!#!#
##  14 ##
sub create_pm_basics {
    my ( $self, $module ) = @_;
    my @layers = split( /::|'/, $module->{NAME} );
    my $file   = pop(@layers);
    my $dir    = join( '/', 'lib', @layers );

    $self->check_dir("$self->{Base_Dir}/$dir");
    $module->{FILE} = "$dir/$file.pm";
}

#!#!#!#!#
##  15 ##
sub initialize_license {
    my ($self) = @_;

    $self->{LICENSE} = lc( $self->{LICENSE} );

    my $license_function = Get_Local_License( $self->{LICENSE} )
      || Get_Standard_License( $self->{LICENSE} );

    if ( ref($license_function) eq 'CODE' ) {
        $self->{LicenseParts} = $license_function->();

        $self->{LicenseParts}{LICENSETEXT} =~
          s/###year###/$self->{COPYRIGHT_YEAR}/ig;
        $self->{LicenseParts}{LICENSETEXT} =~
          s/###owner###/$self->{AUTHOR}{NAME}/ig;
        $self->{LicenseParts}{LICENSETEXT} =~
          s/###organization###/$self->{AUTHOR}{ORGANIZATION}/ig;
    }

}

#!#!#!#!#
##  17 ##
sub module_value {
    my ( $self, $module, @keys ) = @_;

    if ( scalar(@keys) == 1 ) {
        return ( $module->{ $keys[0] } )
          if ( exists( ( $module->{ $keys[0] } ) ) );
        return ( $self->{ $keys[0] } );
    }
    elsif ( scalar(@keys) == 2 ) {
        return ( $module->{ $keys[0] }{ $keys[1] } )
          if ( exists( ( $module->{ $keys[0] }{ $keys[1] } ) ) );
        return ( $self->{ $keys[0] }{ $keys[1] } );
    }
    else {
        return ();
    }
}

sub print_file {
    my ( $self, $filename, $page ) = @_;

    push( @{ $self->{MANIFEST} }, $filename )
      unless ( $filename eq 'MANIFEST' );
    $self->log_message("writing file '$filename'");

    local *FILE;
    open( FILE, ">$self->{Base_Dir}/$filename" )
      or $self->death_message("Could not write '$filename', $!");
    print FILE ($page);
    close FILE;
}

#!#!#!#!#
##  19 ##
# Usage     : check_dir ($dir, $MODE);
# Purpose   : Creates a directory with the correct mode if needed.
# Returns   : n/a
# Argument  : $dir = directory name
#             $MODE = mode of directory (e.g. 0777, 0755)
# Throws    : 
# Comments  : 
sub check_dir {
    my $self = shift;

    return mkpath( \@_, $self->{VERBOSE}, $self->{PERMISSIONS} );
    $self->death_message("Can't create a directory: $!");
}

#!#!#!#!#
##  20 ##
sub death_message {
    my $self = shift;

    die( join "\n", @_, '', $self->{USAGE_MESSAGE} )
      unless $self->{INTERACTIVE};
    print( join "\n", 'Oops, there are the following errors:', @_, '', '' );
}

#!#!#!#!#
##  21 ##
sub log_message {
    my ( $self, $message ) = @_;
    print "$message\n" if $self->{VERBOSE};
}

#!#!#!#!#
##  22 ##
sub pod_section {
    my ( $self, $heading, $content ) = @_;

    my $string = <<ENDOFSTUFF;

 ====head1 $heading

$content
ENDOFSTUFF

    $string =~ s/\n ====/\n=/g;
    return ($string);
}

#!#!#!#!#
##  23 ##
sub pod_wrapper {
    my ( $self, $section ) = @_;

    my $head = <<EOFBLOCK;

########################################### main pod documentation begin ##
# Below is the stub of documentation for your module. You better edit it!

EOFBLOCK

    my $tail = <<EOFBLOCK;

 ====cut

############################################# main pod documentation end ##

EOFBLOCK

    $tail =~ s/\n ====/\n=/g;
    return ( join( '', $head, $section, $tail ) );
}

#!#!#!#!#
##  25 ##
# Usage     : $self->block_begin() within generate_pm_file()
# Purpose   : Build part of a module pm file
# Returns   : Part of the file being built
# Argument  : $module: pointer to the module being built, for the primary
#                      module it is a pointer to $self
# Throws    : n/a
# Comments  : This method is a likely candidate for alteration in a subclass
sub block_begin {
    my ( $self, $module ) = @_;

    my $version = $self->module_value( $module, 'VERSION' );

    my $string = <<EOFBLOCK;
package $module->{NAME};
use strict;

BEGIN {
    use Exporter ();
    use vars qw (\$VERSION \@ISA \@EXPORT \@EXPORT_OK \%EXPORT_TAGS);
    \$VERSION     = $version;
    \@ISA         = qw (Exporter);
    #Give a hoot don't pollute, do not export more than needed by default
    \@EXPORT      = qw ();
    \@EXPORT_OK   = qw ();
    \%EXPORT_TAGS = ();
}

EOFBLOCK

    return ($string);
}

# #!#!#!#!#
##  29 ##
# Usage     : $self->block_new_method() within generate_pm_file()
# Purpose   : Build part of a module pm file
# Returns   : Part of the file being built
# Argument  : $module: pointer to the module being built, for the primary
#                      module it is a pointer to $self
# Throws    : n/a
# Comments  : This method is a likely candidate for alteration in a subclass
sub block_new_method {
    my ( $self, $module ) = @_;

    my $string = <<'EOFBLOCK';

sub new
{
    my ($class, %parameters) = @_;

    my $self = bless ({}, ref ($class) || $class);

    return ($self);
}

EOFBLOCK

    return ($string);
}

#!#!#!#!#
##  31 ##
# Usage     : $self->block_module_header ()
# Purpose   : Build part of a module pm file
# Returns   : Part of the file being built
# Argument  : $module: pointer to the module being built, for the primary
#                      module it is a pointer to $self
# Throws    : n/a
# Comments  : This method is a likely candidate for alteration in a subclass
sub block_module_header {
    my ( $self, $module ) = @_;

    my $description = <<EOFBLOCK;
Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.
EOFBLOCK

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

    return ( $self->pod_wrapper($string) );
}

#!#!#!#!#
##  33 ##
# Usage     : $self->block_subroutine_header() within generate_pm_file()
# Purpose   : Build part of a module pm file
# Returns   : Part of the file being built
# Argument  : $module: pointer to the module being built, for the primary
#                      module it is a pointer to $self
# Throws    : n/a
# Comments  : This method is a likely candidate for alteration in a subclass
sub block_subroutine_header {
    my ( $self, $module ) = @_;

    my $string = <<EOFBLOCK;

################################################ subroutine header begin ##

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

################################################## subroutine header end ##

EOFBLOCK

    $string =~ s/\n ====/\n=/g;
    return ($string);
}

#!#!#!#!#
##  35 ##
# Usage     : $self->block_final_one ()
# Purpose   : Make module return a true value
# Returns   : Part of the file being built
# Argument  : $module: pointer to the module being built, for the primary
#                      module it is a pointer to $self
# Throws    : n/a
# Comments  : This method is a likely candidate for alteration in a subclass
sub block_final_one {
    my ( $self, $module ) = @_;

    my $string = <<EOFBLOCK;

1; #this line is important and will help the module return a true value
__END__

EOFBLOCK

    return ($string);
}

#!#!#!#!#
##  37 ##
# Usage     : $self->file_text_README within complete_build()
# Purpose   : Build a supporting file
# Returns   : Text of the file being built
# Argument  : n/a
# Throws    : n/a
# Comments  : This method is a likely candidate for alteration in a subclass
sub file_text_README {
    my ($self) = @_;

    my $build_instructions;
    if ( $self->{BUILD_SYSTEM} eq 'ExtUtils::MakeMaker' ) {

        $build_instructions = <<EOF;
perl Makefile.PL
make
make test
make install
EOF

    }
    else {

        $build_instructions = <<EOF;
perl Build.PL
./Build
./Build test
./Build install
EOF

    }

    my $page = <<EOF;
pod2text $self->{NAME}.pm > README

If this is still here it means the programmer was too lazy to create the readme file.

You can create it now by using the command shown above from this directory.

At the very least you should be able to use this set of instructions
to install the module...

$build_instructions

If you are on a windows box you should use 'nmake' rather than 'make'.
EOF

    return ($page);
}

#!#!#!#!#
##  39 ##
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
    - original version; created by ExtUtils::ModuleMaker $VERSION


EOF
    }
    else {
        $page = <<EOF;
$self->{VERSION} $self->{timestamp}
    - original version; created by ExtUtils::ModuleMaker $VERSION
EOF
    }

    return ($page);
}

#!#!#!#!#
##  41 ##
# Usage     : $self->file_text_ToDo() within complete_build()
# Purpose   : Build a supporting file
# Returns   : Text of the file being built
# Argument  : n/a
# Throws    : n/a
# Comments  : This method is a likely candidate for alteration in a subclass
sub file_text_ToDo {
    my ($self) = @_;

    my $page = <<EOF;
TODO list for Perl module $self->{NAME}

- Nothing yet


EOF

    return ($page);
}

#!#!#!#!#
##  43 ##
# Usage     : $self->file_text_Makefile 
# Purpose   : Build a supporting file
# Returns   : Text of the file being built
# Argument  : n/a
# Throws    : n/a
# Comments  : This method is a likely candidate for alteration in a subclass
sub file_text_Makefile {
    my ($self) = @_;
    my $page = <<EOF;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => '$self->{NAME}',
    VERSION_FROM => '$self->{FILE}', # finds \$VERSION
    AUTHOR       => '$self->{AUTHOR}{NAME} ($self->{AUTHOR}{EMAIL})',
    ABSTRACT     => '$self->{ABSTRACT}',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
                    },
);
EOF
    return ($page);
}

#!#!#!#!#
##  45 ##
# Usage     : $self->file_text_Buildfile within complete_build() 
# Purpose   : Build a supporting file
# Returns   : Text of the file being built
# Argument  : n/a
# Throws    : n/a
# Comments  : This method is a likely candidate for alteration in a subclass
sub file_text_Buildfile {
    my ($self) = @_;

    # As of 0.15, Module::Build only allows a few licenses
    my $license_line = 1 if $self->{LICENSE} =~ /^(?:perl|gpl|artistic)$/;

    my $page = <<EOF;
use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new
    ( module_name     => '$self->{NAME}',
EOF

    if ($license_line) {

        $page .= <<EOF;
      license         => '$self->{LICENSE}',
EOF

    }

    $page .= <<EOF;
    )->create_build_script;
EOF

    return ($page);

}

#!#!#!#!#
##  47 ##
# Usage     : $self->file_text_proxy_makefile within complete_build()
# Purpose   : Build a supporting file
# Returns   : Text of the file being built
# Argument  : n/a
# Throws    : n/a
# Comments  : This method is a likely candidate for alteration in a subclass
sub file_text_proxy_makefile {
    my ($self) = @_;

    # This comes directly from the docs for Module::Build::Compat
    my $page = <<'EOF';
unless (eval "use Module::Build::Compat 0.02; 1" ) {
  print "This module requires Module::Build to install itself.\n";

  require ExtUtils::MakeMaker;
  my $yn = ExtUtils::MakeMaker::prompt
    ('  Install Module::Build from CPAN?', 'y');

  if ($yn =~ /^y/i) {
    require Cwd;
    require File::Spec;
    require CPAN;

    # Save this 'cause CPAN will chdir all over the place.
    my $cwd = Cwd::cwd();
    my $makefile = File::Spec->rel2abs($0);

    CPAN::Shell->install('Module::Build::Compat');

    chdir $cwd or die "Cannot chdir() back to $cwd: $!";
    exec $^X, $makefile, @ARGV;  # Redo now that we have Module::Build
  } else {
    warn " *** Cannot install without Module::Build.  Exiting ...\n";
    exit 1;
  }
}
Module::Build::Compat->run_build_pl(args => \@ARGV);
Module::Build::Compat->write_makefile();
EOF

    return ($page);
}

#!#!#!#!#
##  49 ##
# Usage     : $self->file_text_test within complete_build()
# Purpose   : Build a supporting file
# Returns   : Text of the file being built
# Argument  : n/a
# Throws    : n/a
# Comments  : This method is a likely candidate for alteration in a subclass
#             Will make a test with or without a checking for method new.
sub file_text_test {
    my ( $self, $testnum, $module ) = @_;

    my $name    = $self->module_value( $module, 'NAME' );
    my $neednew = $self->module_value( $module, 'NEED_NEW_METHOD' );

    my $page;
    if ($neednew) {
        my $name = $module->{NAME};

        $page = <<EOF;
# -*- perl -*-

# $testnum - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( '$name' ); }

my \$object = ${name}->new ();
isa_ok (\$object, '$name');


EOF

    }
    else {

        $page = <<EOF;
# -*- perl -*-

# $testnum - check module loading and create testing directory

use Test::More tests => 1;

BEGIN { use_ok( '$name' ); }


EOF

    }

    return ($page);
}

1;    #this line is important and will help the module return a true value
__END__

#################### DOCUMENTATION ####################

#!#!#!#!#
##   1 ##

=head1 NAME

ExtUtils::ModuleMaker - Better than h2xs for creating modules

=head1 SYNOPSIS

    use ExtUtils::ModuleMaker;

    $mod = ExtUtils::ModuleMaker->new(
        NAME => 'Sample::Module' 
    );
    $mod->complete_build();

=head1 DESCRIPTION

This module is a replacement for the most typical use of the F<h2xs> 
utility bundled with all Perl distributions:  the creation of the 
directories and files required for a pure-Perl module to be distributable 
on the Comprehensive Perl Archive Network (CPAN).

F<h2xs> has many options which are useful -- indeed, necessary -- for 
the creation of a properly structured distribution that includes C code 
as well as Perl code.  Most of the time, however, F<h2xs> is used as follows

    % h2xs -AXn My::Module

to create a distribution containing only Perl code.  ExtUtils::ModuleMaker is 
intended to be an easy-to-use replacement for I<this> use of F<h2xs>.  

While ExtUtils::ModuleMaker can be called from within a Perl script (as in 
the SYNOPSIS above), it is most easily used by a command-prompt invocation 
of the F<modulemaker> script bundled with this distribution:

    % modulemaker

and then responding to the prompts.  For Perl programmers, laziness is a 
virtue -- and F<modulemaker> is far and away the laziest way to create a 
pure Perl distribution which meets all the requirements for worldwide 
distribution via CPAN.

=head1 USAGE

=head2 Usage from the command-line with F<modulemaker>

The easiest, laziest way to use ExtUtils::ModuleMaker is to invoke the 
F<modulemaker> script from the command-line.  See the documentation for 
F<modulemaker> bundled with this distribution.

=head2 Usage within a Perl script

In this version of ExtUtils::ModuleMaker there are only two publicly 
callable functions.  These are how you should interact with this module.

=over 4

=item C<new>

Creates and returns an ExtUtils::ModuleMaker object.  Takes a list 
containing key-value pairs with information specifying the
structure and content of the new module(s).  Like most such lists of
key-value pairs, this list is probably best held in a hash.   Keys 
which may be specified are:

=over 4

=item * NAME

The I<only> required feature.  This is the name of the primary module 
(with 'C<::>' separators if needed).  Will also support the older style 
separator ''C<'>'' like the module F<D'Oh>.  Current default is 'None yet'. 

=item * ABSTRACT

A short (44-character maximum) description of the module.  CPAN likes 
to use this feature to describe the module.

=item * VERSION

A real number to be the version number.  Do not use Linux style numbering 
with multiple dots like 2.4.24.  For alpha releases, include an underscore 
to the right of the dot like 0.31_21. (Default is 0.01.)

=item * LICENSE

Which license to include in the Copyright section.  You can choose one of 
the standard licenses by including 'perl', 'gpl', 'artistic', and 18 others 
approved by opensource.org.  The default is to choose the 'perl' flavor 
which is to share it ''under the same terms as Perl itself.''

Other licenses can be added by individual module authors to 
ExtUtils::ModuleMaker::Licenses::Local to keep your company lawyers happy.

Some licenses include placeholders that will be replaced with AUTHOR 
information.

=item * BUILD_SYSTEM

This can take one of three values.  These are 'ExtUtils::MakeMaker',
'Module::Build', and 'Module::Build and Proxy'.  The first generates a
basic Makefile.PL file for your module.  The second creates a Build.PL
file, and the last creates a Build.PL along with a proxy Makefile.PL
script that attempts to install Module::Build if necessary, and then
runs the Build.PL script.  This option is recommended if you want to
use Module::Build as your build system.  See Module::Build::Compat for
more details.

=item * AUTHOR

A hash containing information about the author to pass on to all the
necessary places in the files.

=over 4

=item * NAME

Name of the author.

=item * EMAIL

Email address of the author.

=item * CPANID

The CPANID of the author.  If this is omitted, then the line will not
be added to the documentation.

=item * WEBSITE

The personal or organizational website of the author.

=item * ORGANIZATION

Company or group owning the module.  If this is omitted, then the line 
will not be added to the documentation

=back

=item * EXTRA_MODULES

An array of hashes that each contain values for additional modules in
the distribution.  As with the primary module only NAME is required and
primary module values will be used if no value is given here.

Each extra module will be created in the correct relative place in the
F<lib> directory, but no extra supporting documents, like README or
Changes.

This is one major improvement over the earlier F<h2xs> as you can now
build multi-module packages.

=item * COMPACT

For a module named ''Foo::Bar::Baz'' creates a base directory named
''Foo-Bar-Baz'' instead of Foo/Bar/Baz. (Default off)

=item * VERBOSE

Prints messages as it creates directories, writes files, etc. (Default off)

=item * INTERACTIVE

Suppresses 'die' when something goes wrong.  Should only be used by interactive
scripts like F<modulemaker>. (Default off)

=item * PERMISSIONS

Used to create new directories.  (Default is 0755:  group and world can not 
write.)

=item * USAGE_MESSAGE

Message given when the module 'die's.  Scripts should set this to the same 
string it would print if the user asked for help (often with a -h flag).

=item * NEED_POD

Include POD section in modules. (Default is on)

=item * NEED_NEW_METHOD

Include a simple 'new' method in the object oriented module.  (Default is on)

=item * CHANGES_IN_POD

Don't include a 'Changes' file, but instead add a HISTORY section to the POD. 
(Default is off).

=back

=item C<complete_build>

Creates all directories and files as configured by the key-value pairs
passed to C<ExtUtils::ModuleMaker::new>.  Returns a
true value if all specified files are created -- but this says nothing
about whether those files have been created with the correct content.

=back

=cut

=head1 SUPPORT

Send email to jkeenan [at] cpan [dot] org.  Please include 'modulemaker'
in the subject line.

=head1 AUTHOR

ExtUtils::ModuleMaker was originally written in 2001-02 by R. Geoffrey Avery
(modulemaker [at] PlatypiVentures [dot] com).  Since version 0.33 (July
2005) it has been maintained by James E. Keenan (jkeenan [at] cpan [dot]
org).

=head1 COPYRIGHT

Copyright (c) 2001-2002 R. Geoffrey Avery. All rights reserved.
This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=head1 SEE ALSO

F<modulemaker>, F<perlnewmod>, F<h2xs>, F<ExtUtils::MakeMaker>.

=cut

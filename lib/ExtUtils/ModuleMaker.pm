package ExtUtils::ModuleMaker;
use strict;
local $^W = 1;
use vars qw ($VERSION);
$VERSION = 0.36_02;

use ExtUtils::ModuleMaker::Licenses::Standard;
use ExtUtils::ModuleMaker::Licenses::Local;
use ExtUtils::ModuleMaker::Defaults qw( default_values );
use File::Path;
use Carp;

#################### PUBLICLY CALLABLE METHODS ####################

#!#!#!#!#
##   2 ##
sub new {
    my ( $class, @arglist ) = @_;
    local $_;
    croak "Must be hash or balanced list of key-value pairs: $!"
        if (@arglist % 2);
    my %parameters = @arglist;
    my @badkeys;
    my %keys_forbidden = map {$_, 1} qw|
        CPANID
        ORGANIZATION
        WEBSITE
        EMAIL
    |;
    for (keys %parameters) {
        push(@badkeys, $_) if $keys_forbidden{$_};
    }
    croak "@badkeys improper top-level key: $!"
        if (@badkeys);

    my $self = ref($class) ? bless( default_values(), ref($class) )
                           : bless( default_values(), $class );
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

#    if ($self->{INTERACTIVE}) { print STDERR "Get data interactively!\n"; }
    $self->set_author_data();
    $self->set_dates();
    $self->initialize_license();

    $self->{MANIFEST} = ['MANIFEST'];
    $self->verify_values();

    return $self;
}

#!#!#!#!#
##   7 ##
sub complete_build {
    my $self = shift;

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
        if ( $self->{BUILD_SYSTEM} eq 'Module::Build and proxy Makefile.PL' 
         or  $self->{BUILD_SYSTEM} eq 'Module::Build and Proxy') {
            $self->print_file( 'Makefile.PL',
                $self->file_text_proxy_makefile() );
        }
    }

    $self->print_file( 'MANIFEST', join( "\n", @{ $self->{MANIFEST} } ) );
    return 1;
}

#################### INTERNAL SUBROUTINES ####################

#!#!#!#!#
##   6 ##
# Usage     : $self->verify_values() within complete_build()
# Purpose   : Verify module values are valid and complete.
# Returns   : Error message if there is a problem
# Argument  : n/a
# Throws    : Will die with a death_message if errors and not interactive.
# Comments  : 
sub verify_values {
    my $self = shift;
    my @errors = ();

    push( @errors, 'NAME is required' )
      unless ( $self->{NAME} );
    push( @errors, 'Module NAME contains illegal characters' )
      unless ( $self->{NAME} and $self->{NAME} =~ m/^[\w:]+$/ );
    push( @errors, 'ABSTRACTs are limited to 44 characters' )
      if ( length( $self->{ABSTRACT} ) > 44 );
    push( @errors, 'CPAN IDs are 3-9 characters' )
      if ( $self->{AUTHOR}{CPANID} !~ m/^\w{3,9}$/ );
    push( @errors, 'EMAIL addresses need to have an at sign' )
      if ( $self->{AUTHOR}{EMAIL} !~ m/.*\@.*/ );
    push( @errors, 'WEBSITEs should start with an "http:" or "https:"' )
      if ( $self->{AUTHOR}{WEBSITE} !~ m/https?:\/\/.*/ );
    push( @errors, 'LICENSE is not recognized' )
      unless ( Verify_Local_License( $self->{LICENSE} )
        || Verify_Standard_License( $self->{LICENSE} ) );

    return unless @errors;
    $self->death_message(\@errors);
}

#!#!#!#!#
##   8 ##
sub generate_pm_file {
    my ( $self, $module ) = @_;

    $self->create_pm_basics($module);

    my $page = $self->build_page($module);

    $self->print_file( $module->{FILE}, $page );
}

sub build_page {
    my $self = shift;
    my $module = shift;
      
    my $page = $self->block_begin($module);
    $page .= (
         ( $self->module_value( $module, 'NEED_POD' ) )
         ? $self->block_module_header($module)
         : ''
    );

    $page .= (
         (
            (
                 ( $self->module_value( $module, 'NEED_POD' ) )
              && ( $self->module_value( $module, 'NEED_NEW_METHOD' ) )
            )
            ? $self->block_subroutine_header($module)
         : ''
	 )
    );

    $page .= (
        ( $self->module_value( $module, 'NEED_NEW_METHOD' ) )
        ? $self->block_new_method($module)
         : ''
    );

    $page .= $self->block_final_one($module);
    return ($module, $page);
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
    my $self = shift;

    $self->{AUTHOR}->{COMPOSITE} = (
        "\t"
         . join( "\n\t",
            $self->{AUTHOR}->{NAME},
            "CPAN ID: $self->{AUTHOR}->{CPANID}", # will need to be modified
            $self->{AUTHOR}->{ORGANIZATION},  # if defaults no longer provided
            $self->{AUTHOR}->{EMAIL}, 
	    $self->{AUTHOR}->{WEBSITE}, ),
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
      join( ( $self->{COMPACT} ) ? '-' : '/', split( /::/, $self->{NAME} ) );
    $self->check_dir( $self->{Base_Dir} );
}

#!#!#!#!#
##  14 ##
sub create_pm_basics {
    my ( $self, $module ) = @_;
    my @layers = split( /::/, $module->{NAME} );
    my $file   = pop(@layers);
    my $dir    = join( '/', 'lib', @layers );

    $self->check_dir("$self->{Base_Dir}/$dir");
    $module->{FILE} = "$dir/$file.pm";
}

#!#!#!#!#
##  15 ##
sub initialize_license {
    my $self = shift;

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
        return;
    }
}

sub print_file {
    my ( $self, $filename, $page ) = @_;

    push( @{ $self->{MANIFEST} }, $filename )
      unless ( $filename eq 'MANIFEST' );
    $self->log_message("writing file '$filename'");

    local *FILE;
    open( FILE, ">$self->{Base_Dir}/$filename" )
      or $self->death_message( [ "Could not write '$filename', $!" ] );
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
    $self->death_message( [ "Can't create a directory: $!" ] );
}

#!#!#!#!#
##  20 ##
sub death_message {
    my $self = shift;
    my $errorref = shift;
    my @errors = @{$errorref};

    croak( join "\n", @errors, '', $self->{USAGE_MESSAGE} )
      unless $self->{INTERACTIVE};
    my %err = map {$_, 1} @errors;
    delete $err{'NAME is required'} if $err{'NAME is required'};
    @errors = keys %err;
    if (@errors) {
        print( join "\n", 
            'Oops, there are the following errors:', @errors, '' );
        return 1;
    } else {
        return;
    }
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
    return $string;
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
    return join( '', $head, $section, $tail );
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

    return $string;
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

    return $self;
}

EOFBLOCK

    return $string;
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

    return $self->pod_wrapper($string);
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
    return $string;
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

EOFBLOCK

    return $string;
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
    my $self = shift;

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

    return $page;
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

    return $page;
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
    my $self = shift;

    my $page = <<EOF;
TODO list for Perl module $self->{NAME}

- Nothing yet


EOF

    return $page;
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
    my $self = shift;
    my $page = sprintf q~

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
~,  map { my $s = $_; $s =~ s{'}{\\'}g; $s; }
    $self->{NAME},
    $self->{FILE},
    $self->{AUTHOR}{NAME},
    $self->{AUTHOR}{EMAIL},
    $self->{ABSTRACT};
    return $page;
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
    my $self = shift;

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

    return $page;

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
    my $self = shift;

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

    return $page;
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

    return $page;
}

sub partial_dump {
    my $self = shift;
    my %keys_not_shown = map {$_, 1} @_;
    require Data::Dumper;
    my ($k, $v, %retry);
    while ( ($k, $v) = each %{$self} ) {
        $retry{$k} = $v unless $keys_not_shown{$k};
    }
    my $d = Data::Dumper->new( [\%retry] );
    return $d->Dump;
}

1;    #this line is important and will help the module return a true value

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

=head1 VERSION

This document references version 0.36_02 of ExtUtils::ModuleMaker, released
to CPAN on July 18, 2005.

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
virtue -- and F<modulemaker> is the laziest way to create a 
pure Perl distribution which meets all the requirements for worldwide 
distribution via CPAN.

=head1 USAGE

=head2 Usage from the command-line with F<modulemaker>

The easiest way to use ExtUtils::ModuleMaker is to invoke the 
F<modulemaker> script from the command-line.  See the documentation for 
F<modulemaker> bundled with this distribution.

=head2 Usage within a Perl script

=head3 Public Methods

In this version of ExtUtils::ModuleMaker there are only two publicly 
callable functions.  These are how you should interact with this module.

=head4 C<new>

Creates and returns an ExtUtils::ModuleMaker object.  Takes a list 
containing key-value pairs with information specifying the
structure and content of the new module(s).  With the exception of 
keys AUTHOR and EXTRA_MODULES (see below), the values in these pairs 
are all strings.  Like most such lists of key-value pairs, this list 
is probably best held in a hash.   Keys which may be specified are:

=over 4

=item * NAME

The I<only> required feature.  This is the name of the primary module 
(with 'C<::>' separators if needed).  Will no longer support the older,
Perl 4-style separator ''C<'>'' like the module F<D'Oh>.  There is no 
current default for NAME.

=item * ABSTRACT

A short (44-character maximum) description of the module.  CPAN likes 
to use this feature to describe the module.  If the abstract contains an
apostrophe (C<'>), then the value corresponding to key C<ABSTRACT> in
the list passed to the constructor must be double-quoted; otherwise
F<Makefile.PL> gets messed up.

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

This can take one of three values:  

=over 4

=item * C<'ExtUtils::MakeMaker'>

The first generates a basic Makefile.PL file for your module.

=item * C<'Module::Build'>

The second creates a Build.PL file.

=item * C<'Module::Build and Proxy'>

The third creates a Build.PL along with a proxy Makefile.PL
script that attempts to install Module::Build if necessary, and then
runs the Build.PL script.  This option is recommended if you want to
use Module::Build as your build system.  See Module::Build::Compat for
more details.

B<Note:>  To correct a discrepancy between the documentation and code in
earlier versions of ExtUtils::ModuleMaker, we now explicitly provide
this synonym for the third option:

    'Module::Build and proxy Makefile.PL'

(Thanks to David A Golden for spotting this bug.)

=back

=item * AUTHOR

A hash containing information about the author to pass on to all the
necessary places in the files.

=over 4

=item * NAME

Name of the author.  If the author's name contains an apostrophe (C<'>), 
then the corresponding value in the list passed to the constructor must 
be double-quoted; otherwise F<Makefile.PL> gets messed up.

=item * EMAIL

Email address of the author.  If the author's e-mail address contains 
an apostrophe (C<'>), then the corresponding value in the list passed 
to the constructor must be double-quoted; otherwise
F<Makefile.PL> gets messed up.

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

=head4 C<complete_build>

Creates all directories and files as configured by the key-value pairs
passed to C<ExtUtils::ModuleMaker::new>.  Returns a
true value if all specified files are created -- but this says nothing
about whether those files have been created with the correct content.

=head3 Private Methods

There are a variety of other ExtUtil::ModuleMaker methods which are not
currently in the public interface.  They are available for you to hack
on, but, as they are primarily used within C<new()> and
C<complete_build()>, their implementation and interface may change in
the future.  See the code for inline documentation.

=head1 CAVEATS

=over 4

=item * Tests Require Perl 5.6

While the maintainer has attempted to make the code in
F<lib/ExtUtils/Modulemaker.pm> and the F<modulemaker> utility compatible
with versions of Perl older than 5.6, the test suite currently requires
5.6 or later.  Eventually, we'll put those tests which absolutely
require 5.6 or later into SKIP blocks so that the tests will run cleanly
on 5.4 or 5.5.

=item * Testing of F<modulemaker>'s Interactive Mode

The easiest, laziest and recommended way of using this distribution is
the command-line utility F<modulemaker>, especially its interactive
mode.  However, this is necessarily the most difficult test, as its
testing would require capturing the STDIN, STDOUT and STDERR for a
process spawned by a C<system('modulemaker')> call from within a test
file.  For now, the maintainer has relied on repeated visual inspection
of the screen prompts generated by F<modulemaker>.

=item * Testing F<modulemaker> on Non-*nix-Like Operating Systems

Since testing the F<modulemaker> utility from within the test suite
requires a C<system()> call, a clean test run depends in part on the way
a given operating system parses command-line arguments.  The maintainer
has tested this on Darwin and Win32 and, thanks to a suggestion by A.
Sinan Unur, solved a problem on Win32.  Results on other operating
systems may differ; feedback is welcome.

=back

=head1 AUTHOR/MAINTAINER

ExtUtils::ModuleMaker was originally written in 2001-02 by R. Geoffrey Avery
(modulemaker [at] PlatypiVentures [dot] com).  Since version 0.33 (July
2005) it has been maintained by James E. Keenan (jkeenan [at] cpan [dot]
org).

=head1 SUPPORT

Send email to jkeenan [at] cpan [dot] org.  Please include 'modulemaker'
in the subject line.

=head1 ACKNOWLEDGMENTS

Thanks to Geoff Avery for inventing and popularizing
ExtUtils::Modulemaker.  Thanks for bug reports and fixes to David A
Golden and an anonymous guest on rt.cpan.org.  Thanks for suggestions
about testing the F<modulemaker> utility to Michael G Schwern on perl.qa
and A Sinan Unur and Paul Lalli on comp.lang.perl.misc.

=head1 COPYRIGHT

Copyright (c) 2001-2002 R. Geoffrey Avery.
Revisions from v0.33 forward (c) 2005 James E. Keenan.  All rights reserved.
This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=head1 SEE ALSO

F<modulemaker>, F<perlnewmod>, F<h2xs>, F<ExtUtils::MakeMaker>.

=cut


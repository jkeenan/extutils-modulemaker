package ExtUtils::ModuleMaker::StandardText;
# as of 08/29/2005
use strict;
local $^W = 1;
use ExtUtils::ModuleMaker::Licenses::Standard qw(
    Get_Standard_License
    Verify_Standard_License
);
use ExtUtils::ModuleMaker::Licenses::Local qw(
    Get_Local_License
    Verify_Local_License
);
use File::Path;
use Carp;

=head1 NAME

ExtUtils::ModuleMaker::StandardText - Methods used within
ExtUtils::ModuleMaker

=head1 DESCRIPTION

The methods described below are 'quasi-private' methods which are called by
the publicly available methods of ExtUtils::ModuleMaker and
ExtUtils::ModuleMaker::Interactive.  They are 'quasi-private' in the sense
that they are not intended to be called by the everyday user of
ExtUtils::ModuleMaker.  But nothing prevents a user from calling these
methods.  Nevertheless, they are documented here primarily so that users
writing plug-ins for ExtUtils::ModuleMaker's standard text know what methods
need to be subclassed.

The descriptions below are presented in hierarchical order rather than
alphabetically.  The order is that of ''how close to the surface can a
particular method called?'', where 'surface' means being called within
C<ExtUtils::ModuleMaker::new()> or C<ExtUtils::ModuleMaker::complete_build()>.
So methods called within one of those two public methods are described before
methods which are only called within other quasi-private methods.  Some of the
methods described are also called within ExtUtils::ModuleMaker::Interactive
methods.  And some quasi-private methods are called within both public and
other quasi-private methods.  Within each heading, methods are presented more
or less as they are first called within the public or higher-order
quasi-private methods.

Happy subclassing!

=head1 METHODS

=head2 Methods Called within C<new()>

=head3 C<set_author_composite>

  Usage     : $self->set_author_composite() within new() and
              Interactive::Main_Menu()
  Purpose   : Sets $self key COMPOSITE by composing it from $self keys AUTHOR,
              CPANID, ORGANIZATION, EMAIL and WEBSITE
  Returns   : n/a
  Argument  : n/a
  Comment   : 

=cut

sub set_author_composite {
    my $self = shift;

    $self->{COMPOSITE} = (
        "\t"
         . join( "\n\t",
            $self->{AUTHOR},
            "CPAN ID: $self->{CPANID}", # will need to be modified
            $self->{ORGANIZATION},  # if defaults no longer provided
            $self->{EMAIL}, 
            $self->{WEBSITE}, 
        ),
    );
}

=head3 C<set_dates()>

  Usage     : $self->set_dates() within new()
  Purpose   : Sets 3 keys in $self:  year, timestamp and COPYRIGHT_YEAR
  Returns   : n/a
  Argument  : n/a
  Comment   : 

=cut

sub set_dates {
    my $self = shift;
    $self->{year}      = (localtime)[5] + 1900;
    $self->{timestamp} = scalar localtime;
    $self->{COPYRIGHT_YEAR} ||= $self->{year};
}

=head3 C<validate_values()>

  Usage     : $self->validate_values() within complete_build() and 
              Interactive::Main_Menu()
  Purpose   : Verify module values are valid and complete.
  Returns   : Error message if there is a problem
  Argument  : n/a
  Throws    : Will die with a death_message if errors and not interactive.
  Comment   : References many $self keys

=cut

sub validate_values {
    my $self = shift;
    my @errors = ();

    push( @errors, 'NAME is required' )
      unless ( $self->{NAME} );
    push( @errors, 'Module NAME contains illegal characters' )
      if ( $self->{NAME} and $self->{NAME} !~ m/^[\w:]+$/ );
    push( @errors, 'ABSTRACTs are limited to 44 characters' )
      if ( length( $self->{ABSTRACT} ) > 44 );
    push( @errors, 'CPAN IDs are 3-9 characters' )
      if ( $self->{CPANID} !~ m/^\w{3,9}$/ );
    push( @errors, 'EMAIL addresses need to have an at sign' )
      if ( $self->{EMAIL} !~ m/.*\@.*/ );
    push( @errors, 'WEBSITEs should start with an "http:" or "https:"' )
      if ( $self->{WEBSITE} !~ m/https?:\/\/.*/ );
    push( @errors, 'LICENSE is not recognized' )
      unless ( Verify_Local_License( $self->{LICENSE} )
        || Verify_Standard_License( $self->{LICENSE} ) );

    return 1 unless @errors;
    $self->death_message(\@errors);
}

=head3 C<initialize_license>

  Usage     : $self->initialize_license() within new() and
              Interactive::License_Menu
  Purpose   : Gets appropriate license and, where necessary, fills in 'blanks'
              with information such as COPYRIGHT_YEAR, AUTHOR and
              ORGANIZATION; sets $self keys LICENSE and LicenseParts
  Returns   : n/a
  Argument  : n/a 
  Comment   :

=cut 

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
          s/###owner###/$self->{AUTHOR}/ig;
        $self->{LicenseParts}{LICENSETEXT} =~
          s/###organization###/$self->{ORGANIZATION}/ig;
    }

}

=head2 Methods Called within C<complete_build()>

=head3 C<create_base_directory>

  Usage     : $self->create_base_directory within complete_build()
  Purpose   : Create the directory where all the files will be created.
  Returns   : $DIR = directory name where the files will live
  Argument  : n/a
  Comment   : $self keys Base_Dir, COMPACT, NAME.  Calls method check_dir.

=cut

sub create_base_directory {
    my $self = shift;

    $self->{Base_Dir} =
      join( ( $self->{COMPACT} ) ? '-' : '/', split( /::/, $self->{NAME} ) );
    $self->check_dir( $self->{Base_Dir} );
}

=head3 C<check_dir()>

  Usage     : check_dir( [ I<list of directories to be built> ] )
              in complete_build; create_base_directory; create_pm_basics 
  Purpose   : Creates directory(ies) requested.
  Returns   : n/a
  Argument  : Reference to an array holding list of directories to be created.
  Comment   : Essentially a wrapper around File::Path::mkpath.  Will use
              values in $self keys VERBOSE and PERMISSIONS to provide 
              2nd and 3rd arguments to mkpath if requested.
  Comment   : Adds to death message in event of failure.

=cut

sub check_dir {
    my $self = shift;

    return mkpath( \@_, $self->{VERBOSE}, $self->{PERMISSIONS} );
    $self->death_message( [ "Can't create a directory: $!" ] );
}

=head3 C<print_file()>

  Usage     : $self->print_file($filename, $filetext) within generate_pm_file()
  Purpose   : Adds the file being created to MANIFEST, then prints text to new
              file.  Logs file creation under verbose.  Adds info for
              death_message in event of failure. 
  Returns   : n/a
  Argument  : 2 arguments: filename and text to be printed
  Comment   : 

=cut

sub print_file {
    my ( $self, $filename, $filetext ) = @_;

    push( @{ $self->{MANIFEST} }, $filename )
      unless ( $filename eq 'MANIFEST' );
    $self->log_message("writing file '$filename'");

    local *FILE;
    open( FILE, ">$self->{Base_Dir}/$filename" )
      or $self->death_message( [ "Could not write '$filename', $!" ] );
    print FILE $filetext;
    close FILE;
}

=head3 C<generate_pm_file>

  Usage     : $self->generate_pm_file($module) within complete_build()
  Purpose   : Create a pm file out of assembled components
  Returns   : n/a
  Argument  : $module: pointer to the module being built
              (as there can be more than one module built by EU::MM);
              for the primary module it is a pointer to $self
  Comment   : 3 components:  create_pm_basics; compose_pm_file; print_file

=cut

sub generate_pm_file {
    my ( $self, $module ) = @_;

    $self->create_pm_basics($module);

    my $page = $self->compose_pm_file($module);

    $self->print_file( $module->{FILE}, $page );
}

=head2 Methods Called within C<complete_build()> as an Argument to C<print_fiile()>

=head3 C<file_text_README()>

  Usage     : $self->file_text_README() within complete_build()
  Purpose   : Build README
  Returns   : String holding text of README
  Argument  : n/a
  Throws    : n/a
  Comment   : Some text held in associated variable $README_text
  Comment   : This method is a likely candidate for alteration in a subclass

=cut

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

=head3 C<file_text_ToDo()>

  Usage     : $self->file_text_ToDo() within complete_build()
  Purpose   : Composes text for ToDo file
  Returns   : String with text of ToDo file
  Argument  : n/a
  Throws    : n/a
  Comment   : This method is a likely candidate for alteration in a subclass
  Comment   : References $self key NAME

=cut

sub file_text_ToDo {
    my $self = shift;

    my $page = <<EOF;
TODO list for Perl module $self->{NAME}

- Nothing yet


EOF

    return $page;
}

=head3 C<file_text_Changes()>

  Usage     : $self->file_text_Changes($only_in_pod) within complete_build; 
              block_module_header()
  Purpose   : Composes text for Changes file
  Returns   : String holding text for Changes file
  Argument  : $only_in_pod:  True value to get only a HISTORY section for POD
                             False value to get whole Changes file
  Throws    : n/a
  Comment   : This method is a likely candidate for alteration in a subclass
  Comment   : Accesses $self keys NAME, VERSION, timestamp, eumm_version

=cut

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

=head3 C<file_text_test()>

  Usage     : $self->file_text_test within complete_build($testnum, $module)
  Purpose   : Composes text for a test for each pm file being requested in
              call to EU::MM
  Returns   : String holding complete text for a test file.
  Argument  : Two arguments: $testnum and $module
  Throws    : n/a
  Comment   : This method is a likely candidate for alteration in a subclass
              Will make a test with or without a checking for method new.

=cut

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

=head3 C<file_text_Makefile()>

  Usage     : $self->file_text_Makefile() within complete_build()
  Purpose   : Build Makefile
  Returns   : String holding text of Makefile
  Argument  : n/a
  Throws    : n/a
  Comment   : This method is a likely candidate for alteration in a subclass

=cut

sub file_text_Makefile {
    my $self = shift;
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
    my $page = sprintf $Makefile_text,
        map { my $s = $_; $s =~ s{'}{\\'}g; $s; }
    $self->{NAME},
    $self->{FILE},
    $self->{AUTHOR},
    $self->{EMAIL},
    $self->{ABSTRACT};
    return $page;
}

=head3 C<file_text_Buildfile()>

  Usage     : $self->file_text_Buildfile() within complete_build() 
  Purpose   : Composes text for a Buildfile for Module::Build
  Returns   : String holding text for Buildfile
  Argument  : n/a
  Throws    : n/a
  Comment   : This method is a likely candidate for alteration in a subclass,
              e.g., respond to improvements in Module::Build
  Comment   : References $self keys NAME and LICENSE

=cut

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

=head3 C<file_text_proxy_makefile()>

  Usage     : $self->file_text_proxy_makefile() within complete_build()
  Purpose   : Composes text for proxy makefile
  Returns   : String holding text for proxy makefile
  Argument  : n/a
  Throws    : n/a
  Comment   : This method is a likely candidate for alteration in a subclass

=cut

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


=head2 Methods Called within C<generate_pm_file()>

=head3 C<create_pm_basics>

  Usage     : $self->create_pm_basics($module) within generate_pm_file()
  Purpose   : Conducts check on directory 
  Returns   : For a given pm file, sets the FILE key: directory/file 
  Argument  : $module: pointer to the module being built
              (as there can be more than one module built by EU::MM);
              for the primary module it is a pointer to $self
  Comment   : References $self keys NAME, Base_Dir, and FILE.  
              Calls method check_dir.

=cut

sub create_pm_basics {
    my ( $self, $module ) = @_;
    my @layers = split( /::/, $module->{NAME} );
    my $file   = pop(@layers);
    my $dir    = join( '/', 'lib', @layers );

    $self->check_dir("$self->{Base_Dir}/$dir");
    $module->{FILE} = "$dir/$file.pm";
}

=head3 C<compose_pm_file()>

  Usage     : $self->compose_pm_file($module) within generate_pm_file()
  Purpose   : Composes a string holding all elements for a pm file
  Returns   : String holding text for a pm file
  Argument  : $module: pointer to the module being built
              (as there can be more than one module built by EU::MM);
              for the primary module it is a pointer to $self
  Comment   : [Method name is inaccurate; it's not building a 'page' but
              rather the text for a pm file.

=cut

sub compose_pm_file {
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
        ? $self->block_new_method()
        : ''
    );

    $page .= $self->block_final_one();
    return ($module, $page);
}


=head2 Methods Called within C<compose_pm_file()>

=head3 C<block_begin()>

  Usage     : $self->block_begin($module) within compose_pm_file()
  Purpose   : Composes the standard code for top of a Perl pm file
  Returns   : String holding code for top of pm file
  Argument  : $module: pointer to the module being built
              (as there can be more than one module built by EU::MM);
              for the primary module it is a pointer to $self
  Throws    : n/a
  Comment   : This method is a likely candidate for alteration in a subclass,
              e.g., you don't need Exporter-related code if you're building 
              an OO-module.
  Comment   : References $self keys NAME and (indirectly) VERSION

=cut

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

=head3 C<module_value()>

  Usage     : $self->module_value($module, @keys) 
              within block_begin(), file_text_test(),
              compose_pm_file(),  block_module_header()
  Purpose   : When writing POD sections, you have to 'escape' 
              the POD markers to prevent the compiler from treating 
              them as real POD.  This method 'unescapes' them and puts header
              and closer around individual POD headings within pm file.
  Arguments : First is pointer to module being formed.  Second is an array
              whose members are the section(s) of the POD being written. 
  Comment   : [The method's name is very opaque and not self-documenting.
              Function of the code is not easily evident.  Rename?  Refactor?]

=cut

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

=head3 C<block_module_header()>

  Usage     : $self->block_module_header($module) inside compose_pm_file()
  Purpose   : Compose the main POD section within a pm file
  Returns   : String holding main POD section
  Argument  : $module: pointer to the module being built
              (as there can be more than one module built by EU::MM);
              for the primary module it is a pointer to $self
  Throws    : n/a
  Comment   : This method is a likely candidate for alteration in a subclass
  Comment   : In StandardText formulation, contains the following components:
              warning about stub documentation needing editing
              pod wrapper top
              NAME - ABSTRACT
              SYNOPSIS
              DESCRIPTION
              USAGE
              BUGS
              SUPPORT
              HISTORY (as requested)
              AUTHOR
              COPYRIGHT
              SEE ALSO
              pod wrapper bottom

=cut

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
            AUTHOR => $self->module_value( $module, 'COMPOSITE' )
        ),
        $self->pod_section(
            COPYRIGHT =>
              $self->module_value( $module, 'LicenseParts', 'COPYRIGHT' )
        ),
        $self->pod_section( 'SEE ALSO' => 'perl(1).' ),
    );

    return $self->pod_wrapper($string);
}

=head3 C<block_subroutine_header()>

  Usage     : $self->block_subroutine_header($module) within compose_pm_file()
  Purpose   : Composes an inline comment for pm file (much like this inline
              comment) which documents purpose of a subroutine
  Returns   : String containing text for inline comment
  Argument  : $module: pointer to the module being built
              (as there can be more than one module built by EU::MM);
              for the primary module it is a pointer to $self
  Throws    : n/a
  Comment   : This method is a likely candidate for alteration in a subclass
              E.g., some may prefer this info to appear in POD rather than
              inline comments.

=cut

sub block_subroutine_header {
    my ( $self, $module ) = @_;
    my $string = <<EOFBLOCK;

#################### subroutine header begin ####################

 ====head2 sample_function

 Usage     : How to use this function/method
 Purpose   : What it does
 Returns   : What it returns
 Argument  : What it wants to know
 Throws    : Exceptions and other anomolies
 Comment   : This is a sample subroutine header.
           : It is polite to include more pod and fewer comments.

See Also   : 

 ====cut

#################### subroutine header end ####################

EOFBLOCK

    $string =~ s/\n ====/\n=/g;
    return $string;
}

=head3 C<block_new_method()>

  Usage     : $self->block_new_method() within compose_pm_file()
  Purpose   : Build 'new()' method as part of a pm file
  Returns   : String holding sub new.
  Argument  : $module: pointer to the module being built
              (as there can be more than one module built by EU::MM);
              for the primary module it is a pointer to $self
  Throws    : n/a
  Comment   : This method is a likely candidate for alteration in a subclass,
              e.g., pass a single hash-ref to new() instead of a list of
              parameters.

=cut

sub block_new_method {
    my $self = shift;
    return <<'EOFBLOCK';

sub new
{
    my ($class, %parameters) = @_;

    my $self = bless ({}, ref ($class) || $class);

    return $self;
}

EOFBLOCK
}

=head3 C<block_final_one()>

  Usage     : $self->block_final_one() within compose_pm_file()
  Purpose   : Compose code and comment that conclude a pm file and guarantee
              that the module returns a true value
  Returns   : String containing code and comment concluding a pm file
  Argument  : $module: pointer to the module being built
              (as there can be more than one module built by EU::MM);
              for the primary module it is a pointer to $self
  Throws    : n/a
  Comment   : This method is a likely candidate for alteration in a subclass,
              e.g., some may not want the comment line included.

=cut

sub block_final_one {
    my $self = shift;
    return <<EOFBLOCK;

1;
# The preceding line will help the module return a true value

EOFBLOCK
}

=head2 All Other Methods

=head3 C<death_message()>

  Usage     : $self->death_message( [ I<list of error messages> ] ) 
              in validate_values; check_dir; print_file
  Purpose   : Croaks with error message composed from elements in the list
              passed by reference as argument
  Returns   : [ To come. ]
  Argument  : Reference to an array holding list of error messages accumulated
  Comment   : Different functioning in modulemaker interactive mode

=cut

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

=head3 C<log_message()>

  Usage     : $self->log_message( $message ) in print_file; 
  Purpose   : Prints log_message (currently, to STDOUT) if $self->{VERBOSE}
  Returns   : n/a
  Argument  : Scalar holding message to be logged
  Comment   : 

=cut

sub log_message {
    my ( $self, $message ) = @_;
    print "$message\n" if $self->{VERBOSE};
}

=head3 C<pod_section()>

  Usage     : $self->pod_section($heading, $content) within 
              block_module_header()
  Purpose   : When writing POD sections, you have to 'escape' 
              the POD markers to prevent the compiler from treating 
              them as real POD.  This method 'unescapes' them and puts header
              and closer around individual POD headings within pm file.
  Arguments : Variables holding POD section name and text of POD section.

=cut

sub pod_section {
    my ( $self, $heading, $content ) = @_;
    my $string = <<ENDOFSTUFF;

 ====head1 $heading

$content
ENDOFSTUFF

    $string =~ s/\n ====/\n=/g;
    return $string;
}

=head3 C<pod_wrapper()>

  Usage     : $self->pod_wrapper($string) within block_module_header()
  Purpose   : When writing POD sections, you have to 'escape' 
              the POD markers to prevent the compiler from treating 
              them as real POD.  This method 'unescapes' them and puts header
              and closer around main POD block in pm file, along with warning
              about stub documentation.
  Argument  : String built up within block_module_header().
  Comment   : Some text held in associated variable %pod_wrapper.

=cut

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
    my ( $self, $string ) = @_;
    my ($head, $tail);
    $head = $pod_wrapper{head};
    $tail = $pod_wrapper{tail};
    $tail =~ s/\n ====/\n=/g;
    return join( '', $head, $string, $tail );
}

1;


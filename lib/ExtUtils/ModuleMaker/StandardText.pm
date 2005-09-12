package ExtUtils::ModuleMaker::StandardText;
# as of 09-12-2005
use strict;
local $^W = 1;
use vars qw ( $VERSION );
$VERSION = '0.39_08';
use ExtUtils::ModuleMaker::Licenses::Standard qw(
    Get_Standard_License
    Verify_Standard_License
);
use ExtUtils::ModuleMaker::Licenses::Local qw(
    Get_Local_License
    Verify_Local_License
);
use File::Path;
use File::Spec;
use Carp;

=head1 NAME

ExtUtils::ModuleMaker::StandardText - Methods used within ExtUtils::ModuleMaker

=head1 DESCRIPTION

The methods described below are 'quasi-private' methods which are called by
the publicly available methods of ExtUtils::ModuleMaker and
ExtUtils::ModuleMaker::Interactive.  They are 'quasi-private' in the sense
that they are not intended to be called by the everyday user of
ExtUtils::ModuleMaker.  But nothing prevents a user from calling these
methods.  Nevertheless, they are documented here primarily so that users
writing plug-ins for ExtUtils::ModuleMaker's standard text know what methods
need to be subclassed.

The methods below are called in C<ExtUtils::ModuleMaker::complet_build()> 
but not in that same package's C<new>.  For methods called in
C<new>, please see ExtUtils::ModuleMaker::Initializers.

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

    $self->{Base_Dir} = File::Spec->rel2abs(
      join( ( $self->{COMPACT} ) ? q{-} : q{/}, split( /::/, $self->{NAME} ) )
    );

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
    $self->log_message( qq{writing file '$filename'});

    my $file = File::Spec->catfile( $self->{Base_Dir}, $filename );
    local *FILE;
    open( FILE, ">$file" )
      or $self->death_message( [ qq{Could not write '$filename', $!} ] );
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

    my $text_of_pm_file = $self->compose_pm_file($module);

    $self->print_file( $module->{FILE}, $text_of_pm_file );
}

=head2 Methods Called within C<complete_build()> as an Argument to C<print_file()>

=head3 C<text_README()>

  Usage     : $self->text_README() within complete_build()
  Purpose   : Build README
  Returns   : String holding text of README
  Argument  : n/a
  Throws    : n/a
  Comment   : This method is a likely candidate for alteration in a subclass

=cut

sub text_README {
    my $self = shift;
    my %README_text = (
        eumm_instructions => <<'END_OF_MAKE',
perl Makefile.PL
make
make test
make install
END_OF_MAKE
        mb_instructions => <<'END_OF_BUILD',
perl Build.PL
./Build
./Build test
./Build install
END_OF_BUILD
        readme_top => <<'END_OF_TOP',

If this is still here it means the programmer was too lazy to create the readme file.

You can create it now by using the command shown above from this directory.

At the very least you should be able to use this set of instructions
to install the module...

END_OF_TOP
        readme_bottom => <<'END_OF_BOTTOM',

If you are on a windows box you should use 'nmake' rather than 'make'.
END_OF_BOTTOM
    );

    my $pod2textline = "pod2text $self->{NAME}.pm > README\n";
    my $build_instructions =
        ( $self->{BUILD_SYSTEM} eq 'ExtUtils::MakeMaker' )
            ? $README_text{eumm_instructions}
            : $README_text{mb_instructions};
    return $pod2textline . 
        $README_text{readme_top} .
        $build_instructions .
        $README_text{readme_bottom};
}

=head3 C<text_Todo()>

  Usage     : $self->text_Todo() within complete_build()
  Purpose   : Composes text for Todo file
  Returns   : String with text of Todo file
  Argument  : n/a
  Throws    : n/a
  Comment   : This method is a likely candidate for alteration in a subclass
  Comment   : References $self key NAME

=cut

sub text_Todo {
    my $self = shift;

    my $text = <<EOF;
TODO list for Perl module $self->{NAME}

- Nothing yet


EOF

    return $text;
}

=head3 C<text_Changes()>

  Usage     : $self->text_Changes($only_in_pod) within complete_build; 
              block_pod()
  Purpose   : Composes text for Changes file
  Returns   : String holding text for Changes file
  Argument  : $only_in_pod:  True value to get only a HISTORY section for POD
                             False value to get whole Changes file
  Throws    : n/a
  Comment   : This method is a likely candidate for alteration in a subclass
  Comment   : Accesses $self keys NAME, VERSION, timestamp, eumm_version

=cut

sub text_Changes {
    my ( $self, $only_in_pod ) = @_;

    my $text_of_Changes;

    unless ($only_in_pod) {
        $text_of_Changes = <<EOF;
Revision history for Perl module $self->{NAME}

$self->{VERSION} $self->{timestamp}
    - original version; created by ExtUtils::ModuleMaker $self->{eumm_version}


EOF
    }
    else {
        $text_of_Changes = <<EOF;
$self->{VERSION} $self->{timestamp}
    - original version; created by ExtUtils::ModuleMaker $self->{eumm_version}
EOF
    }

    return $text_of_Changes;
}

=head3 C<text_test()>

  Usage     : $self->text_test within complete_build($testnum, $module)
  Purpose   : Composes text for a test for each pm file being requested in
              call to EU::MM
  Returns   : String holding complete text for a test file.
  Argument  : Two arguments: $testnum and $module
  Throws    : n/a
  Comment   : This method is a likely candidate for alteration in a subclass
              Will make a test with or without a checking for method new.

=cut

sub text_test {
    my ( $self, $testfilename, $module ) = @_;

    my $name    = $self->module_value( $module, 'NAME' );
    my $neednew = $self->module_value( $module, 'NEED_NEW_METHOD' );

    my %test_file_texts;
    $test_file_texts{neednew} = <<MFNN;
# -*- perl -*-

# $testfilename - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( '$module->{NAME}' ); }

my \$object = ${name}->new ();
isa_ok (\$object, '$module->{NAME}');


MFNN

    $test_file_texts{zeronew} = <<MFZN;
# -*- perl -*-

# $testfilename - check module loading and create testing directory

use Test::More tests => 1;

BEGIN { use_ok( '$module->{NAME}' ); }


MFZN

    return $neednew ? $test_file_texts{neednew}
                    : $test_file_texts{zeronew};
}

sub text_test_multi {
    my ( $self, $testfilename, $pmfilesref ) = @_;
    my @pmfiles = @{$pmfilesref};

    my $top = <<END_OF_TOP;
# -*- perl -*-

# $testfilename - check module loading and create testing directory
END_OF_TOP

    my $number_line = q{use Test::More tests => } . scalar(@pmfiles) . q{;};

    my $begin_block = "BEGIN {\n";
    foreach my $f (@pmfiles) {
        $begin_block .= "    use_ok( '$f->{NAME}' );\n";
    }
    $begin_block .= "}\n";

    my $text_of_test_file = join("\n", (
            $top,
            $number_line,
            $begin_block,
        )
    );
    return $text_of_test_file;
}

#    $test_file_texts{neednew} = <<MTNN;
## -*- perl -*-
#
## $testfilename - check module loading and create testing directory
#
#use Test::More tests => 2;
#
#BEGIN { use_ok( '$module->{NAME}' ); }
#
#my \$object = ${name}->new ();
#isa_ok (\$object, '$module->{NAME}');
#
#
#MTNN
#

=head3 C<text_Makefile()>

  Usage     : $self->text_Makefile() within complete_build()
  Purpose   : Build Makefile
  Returns   : String holding text of Makefile
  Argument  : n/a
  Throws    : n/a
  Comment   : This method is a likely candidate for alteration in a subclass

=cut

sub text_Makefile {
    my $self = shift;
    my $Makefile_format = q~

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
    my $text_of_Makefile = sprintf $Makefile_format,
        map { my $s = $_; $s =~ s{'}{\\'}g; $s; }
            $self->{NAME},
            $self->{FILE},
            $self->{AUTHOR},
            $self->{EMAIL},
            $self->{ABSTRACT};
    return $text_of_Makefile;
}

=head3 C<text_Buildfile()>

  Usage     : $self->text_Buildfile() within complete_build() 
  Purpose   : Composes text for a Buildfile for Module::Build
  Returns   : String holding text for Buildfile
  Argument  : n/a
  Throws    : n/a
  Comment   : This method is a likely candidate for alteration in a subclass,
              e.g., respond to improvements in Module::Build
  Comment   : References $self keys NAME and LICENSE

=cut

sub text_Buildfile {
    my $self = shift;

    # As of 0.15, Module::Build only allows a few licenses
    my $license_line = 1 if $self->{LICENSE} =~ /^(?:perl|gpl|artistic)$/;

    my $text_of_Buildfile = <<EOF;
use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new
    ( module_name     => '$self->{NAME}',
EOF

    if ($license_line) {

        $text_of_Buildfile .= <<EOF;
      license         => '$self->{LICENSE}',
EOF

    }

    $text_of_Buildfile .= <<EOF;
    )->create_build_script;
EOF

    return $text_of_Buildfile;

}

=head3 C<text_proxy_makefile()>

  Usage     : $self->text_proxy_makefile() within complete_build()
  Purpose   : Composes text for proxy makefile
  Returns   : String holding text for proxy makefile
  Argument  : n/a
  Throws    : n/a
  Comment   : This method is a likely candidate for alteration in a subclass

=cut

sub text_proxy_makefile {
    my $self = shift;

    # This comes directly from the docs for Module::Build::Compat
    my $text_of_proxy = <<'EOF';
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

    return $text_of_proxy;
}

=head3 C<text_MANIFEST_SKIP()>

  Usage     : $self->text_MANIFEST_SKIP() within complete_build()
  Purpose   : Composes text for MANIFEST.SKIP file
  Returns   : String with text of MANIFEST.SKIP file
  Argument  : n/a
  Throws    : n/a
  Comment   : References $self key NAME
  Comment   : Adapted from David Golden's ExtUtils::ModuleMaker::TT

=cut

sub text_MANIFEST_SKIP {
    my $self = shift;

    my $text_of_SKIP = <<'END_OF_SKIP';
# Version control files and dirs.
\bRCS\b
\bCVS\b
,v$
.svn/

# ExtUtils::MakeMaker generated files and dirs.
^MANIFEST\.(?!SKIP)
^Makefile$
^blib/
^blibdirs$
^PM_to_blib$
^MakeMaker-\d
                                                                                                                    
# Module::Build
^Build$
^_build

# Temp, old, vi and emacs files.
~$
\.old$
^#.*#$
^\.#
\.swp$
\.bak$
END_OF_SKIP

    return $text_of_SKIP;
}

=head3 C<text_pod_coverage_test()>

  Usage     : $self->text_pod_coverage_test() within complete_build()
  Purpose   : Composes text for t/pod-coverage.t
  Returns   : String with text of t/pod-coverage.t
  Argument  : n/a
  Throws    : n/a
  Comment   : Adapted from Andy Lester's Module::Starter
  Comment   : I don't think of much of this metric, but Andy and Damian do,
              so if you want it you set INCLUDE_POD_COVERAGE_TEST => 1
=cut

sub text_pod_coverage_test {
    my $self = shift;

    my $text_of_pod_coverage_test = <<'END_OF_POD_COVERAGE_TEST';
#!perl -T

use Test::More;
eval "use Test::Pod::Coverage 1.04";
plan skip_all => "Test::Pod::Coverage 1.04 required for testing POD coverage"
    if $@;
all_pod_coverage_ok();
END_OF_POD_COVERAGE_TEST

    return $text_of_pod_coverage_test;
}

=head3 C<text_pod_test()>

  Usage     : $self->text_pod_test() within complete_build()
  Purpose   : Composes text for t/pod.t
  Returns   : String with text of t/pod.t
  Argument  : n/a
  Throws    : n/a
  Comment   : Adapted from Andy Lester's Module::Starter
  Comment   : I don't think of much of this metric, but Andy and Damian do,
              so if you want it you set INCLUDE_POD_TEST => 1
=cut

sub text_pod_test {
    my $self = shift;

    my $text_of_pod_test = <<'END_OF_POD_TEST';
#!perl -T

use Test::More;
eval "use Test::Pod 1.14";
plan skip_all => "Test::Pod 1.14 required for testing POD" if $@;
all_pod_files_ok();
END_OF_POD_TEST

    return $text_of_pod_test;
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
    $file .= '.pm';
#    my $dir    = File::Spec->catdir( 'lib', @layers );
#    my $fulldir = File::Spec->catdir( $self->{Base_Dir}, $dir );
#    $self->check_dir($fulldir);
#    $module->{FILE} = File::Spec->catfile( $dir, $file );
    my $dir         = join( '/', 'lib', @layers );
    my $fulldir     = join( '/',  $self->{Base_Dir}, $dir );
    $self->check_dir($fulldir);
    $module->{FILE} = join( '/', $dir, $file );
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
      
    my $text_of_pm_file = $self->block_begin($module);

    $text_of_pm_file .= (
         (
            (
                 ( $self->module_value( $module, 'NEED_POD' ) )
              && ( $self->module_value( $module, 'NEED_NEW_METHOD' ) )
            )
            ? $self->block_subroutine_header($module)
         : q{}
     )
    );

    $text_of_pm_file .= (
        ( $self->module_value( $module, 'NEED_NEW_METHOD' ) )
        ? $self->block_new_method()
        : q{}
    );

    $text_of_pm_file .= (
         ( $self->module_value( $module, 'NEED_POD' ) )
         ? $self->block_pod($module)
         : q{}
    );

    $text_of_pm_file .= $self->block_final_one();
    return ($module, $text_of_pm_file);
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
    my $package_line  = "package $module->{NAME};\n";
    my $strict_line   = "use strict;\n";
    my $warnings_line = "use warnings;\n";  # not included in standard version
    my $begin_block   = <<"END_OF_BEGIN";

BEGIN {
    use Exporter ();
    use vars qw(\$VERSION \@ISA \@EXPORT \@EXPORT_OK \%EXPORT_TAGS);
    \$VERSION     = '$version';
    \@ISA         = qw(Exporter);
    #Give a hoot don't pollute, do not export more than needed by default
    \@EXPORT      = qw();
    \@EXPORT_OK   = qw();
    \%EXPORT_TAGS = ();
}

END_OF_BEGIN
    my $text = 
        $package_line . 
        $strict_line . 
        # $warnings_line . 
        $begin_block;
    return $text;
}

=head3 C<module_value()>

  Usage     : $self->module_value($module, @keys) 
              within block_begin(), text_test(),
              compose_pm_file(),  block_pod()
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

=head3 C<block_pod()>

  Usage     : $self->block_pod($module) inside compose_pm_file()
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

sub block_pod {
    my ( $self, $module ) = @_;

    my $name             = $self->module_value( $module, 'NAME' );
    my $abstract         = $self->module_value( $module, 'ABSTRACT' );
    my $synopsis         = qq{  use $name;\n  blah blah blah\n};
    my $description      = <<END_OF_DESC;
Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.
END_OF_DESC
    my $author_composite = $self->module_value( $module, 'COMPOSITE' );
    my $copyright        = $self->module_value( $module, 'LicenseParts', 'COPYRIGHT');
    my $see_also         = q{perl(1).};

    my $text_of_pod = join(
        q{},
        $self->pod_section( NAME => $name . 
            ( (defined $abstract) ? qq{ - $abstract} : q{} )
        ),
        $self->pod_section( SYNOPSIS    => $synopsis ),
        $self->pod_section( DESCRIPTION => $description ),
        $self->pod_section( USAGE       => q{} ),
        $self->pod_section( BUGS        => q{} ),
        $self->pod_section( SUPPORT     => q{} ),
        (
            ( $self->{CHANGES_IN_POD} )
            ? $self->pod_section(
                HISTORY => $self->text_Changes('only pod')
              )
            : q{}
        ),
        $self->pod_section( AUTHOR     => $author_composite),
        $self->pod_section( COPYRIGHT  => $copyright),
        $self->pod_section( 'SEE ALSO' => $see_also),
    );

    return $self->pod_wrapper($text_of_pod);
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
    my $text_of_subroutine_pod = <<EOFBLOCK;

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

    $text_of_subroutine_pod =~ s/\n ====/\n=/g;
    return $text_of_subroutine_pod;
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

    croak( join "\n", @errors, q{}, $self->{USAGE_MESSAGE} )
      unless $self->{INTERACTIVE};
    my %err = map {$_, 1} @errors;
    delete $err{'NAME is required'} if $err{'NAME is required'};
    @errors = keys %err;
    if (@errors) {
        print( join "\n", 
            'Oops, there are the following errors:', @errors, q{} );
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
              block_pod()
  Purpose   : When writing POD sections, you have to 'escape' 
              the POD markers to prevent the compiler from treating 
              them as real POD.  This method 'unescapes' them and puts header
              and closer around individual POD headings within pm file.
  Arguments : Variables holding POD section name and text of POD section.

=cut

sub pod_section {
    my ( $self, $heading, $content ) = @_;
    my $text_of_pod_section = <<END_OF_SECTION;

 ====head1 $heading

$content
END_OF_SECTION

    $text_of_pod_section =~ s/\n ====/\n=/g;
    return $text_of_pod_section;
}

=head3 C<pod_wrapper()>

  Usage     : $self->pod_wrapper($string) within block_pod()
  Purpose   : When writing POD sections, you have to 'escape' 
              the POD markers to prevent the compiler from treating 
              them as real POD.  This method 'unescapes' them and puts header
              and closer around main POD block in pm file, along with warning
              about stub documentation.
  Argument  : String holding text of POD which has been built up 
              within block_pod().
  Comment   : $head and $tail inside pod_wrapper() are optional and, in a 
              subclass, could be redefined as empty strings;
              but $cutline is mandatory as it supplies the last =cut

=cut

sub pod_wrapper {
    my ( $self, $podtext ) = @_;
    my $head = <<'END_OF_HEAD';

#################### main pod documentation begin ###################
## Below is the stub of documentation for your module. 
## You better edit it!

END_OF_HEAD
    my $cutline = <<'END_OF_CUT';

 ====cut

END_OF_CUT
    my $tail = <<'END_OF_TAIL';
#################### main pod documentation end ###################

END_OF_TAIL

    $cutline =~ s/\n ====/\n=/g;
    return join( q{}, 
        $head,     # optional
        $podtext,  # required 
        $cutline,  # required 
        $tail      # optional
    );
}

1;


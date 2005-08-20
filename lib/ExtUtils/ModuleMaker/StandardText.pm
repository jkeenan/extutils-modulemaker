package ExtUtils::ModuleMaker::StandardText;
# as of 08/16/2005
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

# Usage     : $self->file_text_Makefile 
# Purpose   : Build a supporting file
# Returns   : Text of the file being built
# Argument  : n/a
# Throws    : n/a
# Comments  : This method is a likely candidate for alteration in a subclass
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
#    $self->{AUTHOR}{NAME},
    $self->{AUTHOR},
#    $self->{AUTHOR}{EMAIL},
    $self->{EMAIL},
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

# Usage     : $self->block_new_method() within generate_pm_file()
# Purpose   : Build part of a module pm file
# Returns   : Part of the file being built
# Argument  : $module: pointer to the module being built, for the primary
#                      module it is a pointer to $self
# Throws    : n/a
# Comments  : This method is a likely candidate for alteration in a subclass
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
#            AUTHOR => $self->module_value( $module, 'AUTHOR', 'COMPOSITE' )
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

    $string =~ s/\n ====/\n=/g;
    return $string;
}

# Usage     : $self->block_final_one ()
# Purpose   : Make module return a true value
# Returns   : Part of the file being built
# Argument  : $module: pointer to the module being built, for the primary
#                      module it is a pointer to $self
# Throws    : n/a
# Comments  : This method is a likely candidate for alteration in a subclass
sub block_final_one {
    my $self = shift;
#    $block_final_one;
    return <<EOFBLOCK;

1;
# The preceding line will help the module return a true value

EOFBLOCK
}

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
      if ( $self->{NAME} and $self->{NAME} !~ m/^[\w:]+$/ );
    push( @errors, 'ABSTRACTs are limited to 44 characters' )
      if ( length( $self->{ABSTRACT} ) > 44 );
    push( @errors, 'CPAN IDs are 3-9 characters' )
#      if ( $self->{AUTHOR}{CPANID} !~ m/^\w{3,9}$/ );
      if ( $self->{CPANID} !~ m/^\w{3,9}$/ );
    push( @errors, 'EMAIL addresses need to have an at sign' )
#      if ( $self->{AUTHOR}{EMAIL} !~ m/.*\@.*/ );
      if ( $self->{EMAIL} !~ m/.*\@.*/ );
    push( @errors, 'WEBSITEs should start with an "http:" or "https:"' )
#      if ( $self->{AUTHOR}{WEBSITE} !~ m/https?:\/\/.*/ );
      if ( $self->{WEBSITE} !~ m/https?:\/\/.*/ );
    push( @errors, 'LICENSE is not recognized' )
      unless ( Verify_Local_License( $self->{LICENSE} )
        || Verify_Standard_License( $self->{LICENSE} ) );

    return unless @errors;
    $self->death_message(\@errors);
}

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
        ? $self->block_new_method()
        : ''
    );

    $page .= $self->block_final_one();
    return ($module, $page);
}

sub set_dates {
    my $self = shift;
    $self->{year}      = (localtime)[5] + 1900;
    $self->{timestamp} = scalar localtime;
    $self->{COPYRIGHT_YEAR} ||= $self->{year};
}

sub set_author_data {
    my $self = shift;

#    $self->{AUTHOR}->{COMPOSITE} = (
    $self->{COMPOSITE} = (
        "\t"
         . join( "\n\t",
#            $self->{AUTHOR}->{NAME},
            $self->{AUTHOR},
#            "CPAN ID: $self->{{AUTHOR}->CPANID}", # will need to be modified
            "CPAN ID: $self->{CPANID}", # will need to be modified
#            $self->{AUTHOR}->{ORGANIZATION},  # if defaults no longer provided
            $self->{ORGANIZATION},  # if defaults no longer provided
#            $self->{AUTHOR}->{EMAIL}, 
            $self->{EMAIL}, 
#           $self->{AUTHOR}->{WEBSITE}, ),
            $self->{WEBSITE}, 
        ),
    );
}

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

sub create_pm_basics {
    my ( $self, $module ) = @_;
    my @layers = split( /::/, $module->{NAME} );
    my $file   = pop(@layers);
    my $dir    = join( '/', 'lib', @layers );

    $self->check_dir("$self->{Base_Dir}/$dir");
    $module->{FILE} = "$dir/$file.pm";
}

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
#          s/###owner###/$self->{AUTHOR}{NAME}/ig;
          s/###owner###/$self->{AUTHOR}/ig;
        $self->{LicenseParts}{LICENSETEXT} =~
#          s/###organization###/$self->{AUTHOR}{ORGANIZATION}/ig;
          s/###organization###/$self->{ORGANIZATION}/ig;
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

sub log_message {
    my ( $self, $message ) = @_;
    print "$message\n" if $self->{VERBOSE};
}

1;


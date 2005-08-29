package ExtUtils::ModuleMaker::Utility;
# as of 08/27/2005
use strict;
local $^W = 1;
use Carp;
use File::Path;

BEGIN {
    use Exporter ();
    use vars qw ( @ISA @EXPORT_OK );
#    $VERSION     : taken from lib/ExtUtils/ModuleMaker.pm
    @ISA         = qw(Exporter);
    @EXPORT_OK   = qw(
        _get_home_directory
        _get_personal_defaults_directory
        _restore_personal_dir_status
    );
}

sub _get_home_directory {
    my $realhome;
    if ($^O eq 'MSWin32') {
        require Win32;
        Win32->import( qw(CSIDL_LOCAL_APPDATA) );  # 0x001c 
        $realhome =  Win32::GetFolderPath( CSIDL_LOCAL_APPDATA() );
        return $realhome if (-d $realhome);
        $realhome =~ s|(.*?)\\Local Settings(.*)|$1$2|;
        return $realhome if (-d $realhome);
        croak "Unable to identify directory equivalent to 'HOME' on Win32: $!";
    } else { # Unix-like systems
        $realhome = $ENV{HOME};
        return $realhome if (-d $realhome);
        croak "Unable to identify 'HOME' directory: $!";
    }
}

sub _get_personal_defaults_directory {
    my ($realhome, $personal_dir, $no_personal_dir_flag); 
    if ($^O eq 'MSWin32') {
        $realhome = _get_home_directory();
        $personal_dir = "$realhome/.modulemaker"; 
        if (! -d $personal_dir) {
            $no_personal_dir_flag++; 
            mkdir $personal_dir
                or croak "Unable to make directory $personal_dir for placement of personal defaults file on Win32: $!";
        }
    } else { # Unix-like systems
        $realhome = _get_home_directory();
        $personal_dir = "$realhome/.modulemaker"; 
        if (! -d $personal_dir) {
            $no_personal_dir_flag++; 
            mkdir $personal_dir
                or croak "Unable to make directory $personal_dir for placement of personal defaults file underneath 'HOME': $!";
        }
    }
    return ($personal_dir, $no_personal_dir_flag);
}

sub _restore_personal_dir_status {
    my $personal_dir = shift;
    my $no_personal_dir_flag = shift;
    # 1 means there was NO .modulemaker directory at start of test file
    # 0 means there was such a directory
    if ($no_personal_dir_flag) {
        rmtree($personal_dir, 0, 1);
        if(! -d $personal_dir) {
            return 1;
        } else {
            croak "Unable to restore .modulemaker directory created during test: $!";
        }
    } else {
        return 1;
    }
}

1;

#################### DOCUMENTATION ####################

=head1 NAME

ExtUtils::ModuleMaker::Utility - Utility subroutines for EU::MM

=head1 SYNOPSIS

  use ExtUtils::ModuleMaker::Utility qw( _get_personal_defaults_directory );
  ...
  $home_dir     = _get_home_directory();
  $personal_dir = _get_personal_defaults_directory();

=head1 DESCRIPTION

This package holds utility subroutines imported and used by
ExtUtils::ModuleMaker and/or its test suite.

=head1 USAGE

=over 4

=item * C<_get_home_directory()>

Analyzes environmental information to determine whether there exists on the
system a 'HOME' or 'home-equivalent' directory capable of holding directories
which, in turn, will be appropriate for
holding an ExtUtils::ModuleMaker::Personal::Defaults package.  On Win32, this
directory is that returned by the following function from the F<Win32>module:

    Win32->import( qw(CSIDL_LOCAL_APPDATA) );
    $realhome =  Win32::GetFolderPath( CSIDL_LOCAL_APPDATA() );

... which translates to something like F<C:\Documents and Settings\localuser\Local Settings\Application Data>.  
Well, not quite.  On some systems, that directory does not exist.  What does
exist is the same path less the F<Local Settings\\> level. So we run
C<$realhome> through a regex to eliminate that.

    $realhome =~ s|(.*?)\\Local Settings(.*)|$1$2|;

On Unix-like systems, things are much simpler.  We simply check the value of
C<$ENV{HOME}>.  We cannot do that on Win32 (at least not on ActivePerl),
because C<$ENV{HOME}> is not defined there.

=item * C<_get_personal_defaults_directory()>

Once we have established that there exists an appropriate 'HOME' or home-like
directory, we create a directory F<.modulemaker> underneath it.  This in turn
will hold  ExtUtils::ModuleMaker::Personal::Defaults.

C<_get_personal_defaults_directory()> calls C<_get_home_directory()>
internally, so if you are using C<_get_personal_defaults_directory()> you do
not need to call C<_get_home_directory()> first.

=back

=head1 BUGS

So far checked only on Win32 (WindowsXP Pro) and Darwin.

=head1 AUTHOR/MAINTAINER

James E Keenan (jkeenan [at] cpan [dot] org).

=head1 SUPPORT

Send email to jkeenan [at] cpan [dot] org.  Please include 'modulemaker'
in the subject line.

=head1 COPYRIGHT

Copyright (c) 2005 James E. Keenan.  All rights reserved.
This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=head1 SEE ALSO

F<ExtUtils::ModuleMaker>, F<modulemaker>, perl(1).

=cut



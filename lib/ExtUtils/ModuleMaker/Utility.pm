package ExtUtils::ModuleMaker::Utility;
# as of 09-05-2005
use strict;
local $^W = 1;
use base qw(Exporter);
use vars qw( @EXPORT_OK $VERSION );
$VERSION = '0.39_02';
@EXPORT_OK   = qw(
    _get_home_directory
    _preexists_mmkr_directory
    _make_mmkr_directory
    _restore_mmkr_dir_status
);
use Carp;
use File::Path;

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

# if the modulemaker environmental variable has been set administratively,
# return its contents;
# otherwise, formulate a directory name from the home directory
sub _get_mmkr_directory {
    return (defined $ENV{modulemaker})
        ? $ENV{modulemaker}
        : _get_home_directory() . "/.modulemaker";
}

sub _preexists_mmkr_directory {
    my $dirname = _get_mmkr_directory(); 
    if (-d $dirname) {
        return [$dirname, 1];
    } else {
        return [$dirname, undef];
    }
}

sub _make_mmkr_directory {
    my $mmkr_dir_ref = shift;
    my $dirname = $mmkr_dir_ref->[0];
    if (! -d $dirname) {
        mkdir $dirname
            or croak "Unable to make directory $dirname for placement of personal defaults file or subclass: $!";
    }
    return $dirname;
}

sub _restore_mmkr_dir_status {
    my $mmkr_dir_ref = shift;
    my $mmkr_dir = $mmkr_dir_ref->[0];
    if (! defined $mmkr_dir_ref->[1]) {
        rmtree($mmkr_dir, 0, 1);
        if(! -d $mmkr_dir) {
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

  use ExtUtils::ModuleMaker::Utility qw( _make_mmkr_directory );

  $home_dir = _get_home_directory();
  
  ($mmkr_dir, $no_mmkr_dir_flag) = _make_mmkr_directory();

  _restore_mmkr_dir_status($mmkr_dir, $no_mmkr_dir_flag),

=head1 DESCRIPTION

This package holds utility subroutines imported and used by
ExtUtils::ModuleMaker and/or its test suite.

=head1 USAGE

=over 4

=item * C<_get_home_directory()>

Analyzes environmental information to determine whether there exists on the
system a 'HOME' or 'home-equivalent' directory.  Returns that directory if it
exists; C<croak>s otherwise.

On Win32, this directory is the one returned by the following function from the F<Win32>module:

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

=item * C<_make_mmkr_directory()>

Returns a two-element list.  The first element is the name of a directory.  
The second is a flag indicating whether that directory already existed (C<undef>)
or whether the method call had to create that directory (a true value).  The
directory so returned will be one capable of holding directories and files
particular to ExtUtils::Modulemaker's functioning on your system (I<e.g.,>
holding F<ExtUtils/ModuleMaker/Personal/Defaults.pm>).  The flag is used only
within ExtUtils::Modulemaker's test suite.

If ExtUtils::ModuleMaker has already been installed on your system, it is
possible that you or your system administrator has assigned a particular
directory (outside the normal site location for Perl modules) to serve as 
the location to hold other directories which in turn hold site-specific 
default or configuration files for ExtUtils::ModuleMaker.  Such a 
directory would be assigned to an environmental variable C<modulemaker>, 
represented within Perl code as C<$ENV{modulemaker}>.
If such a directory exists, C<_make_mmkr_directory()> returns it
and it will hold ExtUtils::ModuleMaker::Personal::Defaults.

If, as is more likely, C<$ENV{modulemaker}> has I<not> been set, then
C<_make_mmkr_directory()> checks (via an internal call to
C<_get_home_directory>) to see whether there exists an appropriate 'HOME' 
or home-like directory on your system and whether there is a F<.modulemaker> 
directory underneath it.  If so, C<_make_mmkr_directory()> 
returns it; if not, the method call creates and returns it, C<croak>ing 
upon failure.  If the directory was I<not> there originally, we set the 
C<$no_mmkr_dir_flag> to a true value and return it as the second return
value from C<_make_mmkr_directory()>; otherwise that 
variable returns as C<undef>.  The F<.modulemaker> directory created will 
hold ExtUtils::ModuleMaker::Personal::Defaults.

C<_make_mmkr_directory()> calls C<_get_home_directory()>
internally, so if you are using C<_make_mmkr_directory()> you do
not need to call C<_get_home_directory()> first.

=item * C<_restore_mmkr_dir_status()>

Undoes C<_make_mmkr_directory()>, I<i.e.,> if there was no
F<.modulemaker> directory on the user's system before testing, any such
directory created during testing is removed.  On the other hand, if there
I<was> such a directory present before testing, it is left unchanged.

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



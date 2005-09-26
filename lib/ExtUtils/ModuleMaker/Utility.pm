package ExtUtils::ModuleMaker::Utility;
# as of 09-26-2005
use strict;
local $^W = 1;
use base qw(Exporter);
use vars qw( @EXPORT_OK $VERSION );
$VERSION = '0.41_02';
@EXPORT_OK   = qw(
    _get_home_directory
    _get_mmkr_directory
    _preexists_mmkr_directory
    _make_mmkr_directory
    _restore_mmkr_dir_status
    _get_dir_and_file
);
use Carp;
use File::Path;

=head1 NAME

ExtUtils::ModuleMaker::Utility - Utility subroutines for EU::MM

=head1 SYNOPSIS

    use ExtUtils::ModuleMaker::Utility qw(
        _get_home_directory
        _get_mmkr_directory
        _preexists_mmkr_directory
        _make_mmkr_directory
        _restore_mmkr_dir_status
        _get_dir_and_file
    );

    $home_dir = _get_home_directory();

    $mmkr_dir = _get_mmkr_directory();

    $dirref = _preexists_mmkr_directory();

    ($mmkr_dir, $no_mmkr_dir_flag) = _make_mmkr_directory();

    _restore_mmkr_dir_status($mmkr_dir, $no_mmkr_dir_flag),

    ($dir, $file) = _get_dir_and_file($module);

=head1 DESCRIPTION

This package holds utility subroutines imported and used by
ExtUtils::ModuleMaker and/or its test suite.  The subroutines exist primarily
to eliminate blocks of repeated code.

=head1 USAGE

=head2 C<_get_home_directory()>

Analyzes environmental information to determine whether there exists on the
system a 'HOME' or 'home-equivalent' directory.  Returns that directory if it
exists; C<croak>s otherwise.

On Win32, this directory is the one returned by the following function from the F<Win32>module:

    Win32->import( qw(CSIDL_LOCAL_APPDATA) );
    $realhome =  Win32::GetFolderPath( CSIDL_LOCAL_APPDATA() );

... which translates to something like F<C:\Documents and Settings\localuser\Local Settings\Application Data>.  

Well, not quite.  On some systems, that directory does not exist or is hidden. 
What does exist is the same path less the F<Local Settings\\> level. So we run
C<$realhome> through a regex to eliminate that.

    $realhome =~ s|(.*?)\\Local Settings(.*)|$1$2|;

On Unix-like systems, things are much simpler.  We simply check the value of
C<$ENV{HOME}>.  We cannot do that on Win32 (at least not on ActivePerl),
because C<$ENV{HOME}> is not defined there.

=cut

sub _get_home_directory {
    my $realhome;
    if ($^O eq 'MSWin32') {
        require Win32;
        Win32->import( qw(CSIDL_LOCAL_APPDATA) );  # 0x001c 
        $realhome =  Win32::GetFolderPath( CSIDL_LOCAL_APPDATA() );
        $realhome =~ s{ }{\ }g;
        return $realhome if (-d $realhome);
        $realhome =~ s|(.*?)\\Local Settings(.*)|$1$2|;
        return $realhome if (-d $realhome);
        croak "Unable to identify directory equivalent to 'HOME' on Win32: $!";
    } else { # Unix-like systems
        $realhome = $ENV{HOME};
        $realhome =~ s{ }{\ }g;
        return $realhome if (-d $realhome);
        croak "Unable to identify 'HOME' directory: $!";
    }
}

=head2 C<_get_mmkr_directory()>

If the modulemaker environmental variable (C<$ENV{modulemaker}>) has been 
set administratively, return its contents.  Otherwise, compose a directory 
name from the home directory.  Note:  This subroutine
simply returns the I<name> of a path; it does not check for the path's
existence as a directory.

=cut

sub _get_mmkr_directory {
    return (defined $ENV{modulemaker})
        ? $ENV{modulemaker}
        : _get_home_directory() . "/.modulemaker";
}

=head2 C<_preexists_mmkr_directory()>

Internally calls C<_get_mmkr_directory()> to get an appropriate name for a
directory.  Returns a reference to an array holding a two-element list.  
The first element is that directory name.  The second is a flag indicating 
whether that directory already exists (a true value) or not  (C<undef>).  
The flag is used only within ExtUtils::Modulemaker's test suite.

=cut

sub _preexists_mmkr_directory {
    my $dirname = _get_mmkr_directory(); 
    if (-d $dirname) {
        return [$dirname, 1];
    } else {
        return [$dirname, undef];
    }
}

=head2 C<_make_mmkr_directory()>

Takes as argument the array reference returned by
C<_preexists_mmkr_directory()>. Examines the first element in that array --
the directory name -- and creates the directory if it doesn't already exist.
The function C<croak>s if the directory cannot be created.

=cut

sub _make_mmkr_directory {
    my $mmkr_dir_ref = shift;
    my $dirname = $mmkr_dir_ref->[0];
    if (! -d $dirname) {
        mkdir $dirname
            or croak "Unable to make directory $dirname for placement of personal defaults file or subclass: $!";
    }
    return $dirname;
}

=head2 C<_restore_mmkr_dir_status()>

Undoes C<_make_mmkr_directory()>, I<i.e.,> if there was no
F<.modulemaker> directory on the user's system before testing, any such
directory created during testing is removed.  On the other hand, if there
I<was> such a directory present before testing, it is left unchanged.

=cut

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

=head2 C<_get_dir_and_file()>

  Usage     : _get_dir_and_file($module) within generate_pm_file()
  Purpose   : Get directory and name for .pm file being processed
  Returns   : 2-element list: First $dir; Second: $file
  Argument  : $module: pointer to the module being built
              (as there can be more than one module built by EU::MM);
              for the primary module it is a pointer to $self
  Comment   : Merely a utility subroutine to refactor code; not a method call.

=cut

sub _get_dir_and_file {
    my $module = shift;
    my @layers      = split( /::/, $module->{NAME} );
    my $file        = pop(@layers) . '.pm';
    my $dir         = join( '/', 'lib', @layers );
    return ($dir, $file);
}

1;

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

F<ExtUtils::ModuleMaker>.

=cut

__END__

The
directory so returned will be one capable of holding directories and files
particular to ExtUtils::Modulemaker's functioning on your system (I<e.g.,>
holding F<ExtUtils/ModuleMaker/Personal/Defaults.pm>)..

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


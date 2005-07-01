
package ExtUtils::ModuleMaker;
use strict;

use ExtUtils::ModuleMaker::Licenses::Standard;
use ExtUtils::ModuleMaker::Licenses::Local;
use File::Path;

BEGIN {
	use Exporter ();
	use vars qw ($VERSION @ISA @EXPORT);
	@ISA		= qw (Exporter);
	@EXPORT		= qw (&Generate_Module_Files &Quick_Module);
	$VERSION     = 0.32;
}

########################################### main pod documentation begin ##

=head1 NAME

ExtUtils::ModuleMaker - Better than h2xs, for creating all the parts of modules

=head1 SYNOPSIS

  use ExtUtils::ModuleMaker;
  #die "You really don't want to use ModuleMaker again for this module."

  my $MOD = ExtUtils::ModuleMaker->new
              (
                NAME => 'Sample::Module',
              );
  $MOD->complete_build ();

=head1 DESCRIPTION

This module is a replacement for h2xs.  It can be called from a Modulefile.PL
similar to calling MakeMaker from Makefile.PL.

See also: the 'modulemaker' program, which is included with this package, that simplifies
the process for casual module builders; the vast majority of lazy Perl programmers.

=head1 INSTALLATION

  perl Makefile.PL
  make
  make test
  make install

On windows machines use nmake rather than make.  If you would like to
test the scripts without a real installation you can replace
Makefile.PL with Fakefile.PL to install in a temporaty place.

=head1 USAGE

=head1 BUGS

=head1 SUPPORT

Send email to modulemaker@PlatypiVentures.com.

=head1 AUTHOR

	R. Geoffrey Avery
	CPAN ID: RGEOFFREY
	modulemaker@PlatypiVentures.com
	http://www.PlatypiVentures.com/perl/modules/ModuleMaker.shtml

=head1 COPYRIGHT

Copyright (c) 2001-20022 R. Geoffrey Avery. All rights reserved.
This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=head1 SEE ALSO

L<modulemaker>, L<perlnewmod>, L<h2xs>, L<ExtUtils::MakeMaker>

=head1 PUBLIC METHODS

Each public function/method is described here.
These are how you should interact with this module.

=cut

############################################# main pod documentation end ##


# Public methods and functions go here. 

################################################ subroutine header begin ##

=head2 new

 Usage     : 
 Purpose   : Creates an object for modules
 Returns   : the module object
 Argument  : A hash with the information for the new module(s)
 Throws    : 
 Comments  : 

See Also   : 

=over 4

=item NAME

The only required feature.  This is the name of the primary module (with '::' separators if needed).
Will also support the older style separator "'" like the module D'Oh.

=item ABSTRACT

A short description of the module.  CPAN likes to use this feature to describe the module.

=item VERSION

A real number to be the version number.  Do not use Linux style numbering with multiple dots
like 2.4.24.  For alpha releases include an underscore to the right of the dot like 0.31_21. (Default is 0.01)

=item LICENSE

Which license to include in the Copyright section.  You can choose one of the standard licenses by
including 'perl', 'gpl', 'artistic', and 18 others approved by opensource.org.
The default is to choose the 'perl' flavor which is to
share it "under the same terms as Perl itself".

Other licenses can be added by individual module authors to ExtUtils::ModuleMaker::Licenses::Local
to keep your company lawyers happy.

Some licenses include placeholders that will be replaced with AUTHOR information.

=item BUILD_SYSTEM

This can take one of three values.  These are 'ExtUtils::MakeMaker',
'Module::Build', and 'Module::Build and Proxy'.  The first generates a
basic Makefile.PL file for your module.  The second creates a Build.PL
file, and the last creates a Build.PL along with a proxy Makefile.PL
script that attempts to install Module::Build if necessary, and then
runs the Build.PL script.  This option is recommended if you want to
use Module::Build as your build system.  See Module::Build::Compat for
more details.


=item AUTHOR

A hash containing information about the author to pass on to all the
necessary places in the files.

=over 4

=item NAME

Name of the author.

=item EMAIL

Email address of the author.

=item CPANID

The CPANID of the author.  If this is omited, then the line will not
be added to the documentation.

=item WEBSITE

The personal or organizational website of the author.

=item ORGANIZATION

Company or group owning the module.

=back

=item EXTRA_MODULES

An array of hashes that each contain values for additional modules in
the distribution.  As with the primary module only NAME is required and
primary module values will be used if no value is given here.

Each extra module will be created in the correct relative place in the
B<lib> directory, but no extra supporting documents, like README or
Changes.

This is one major improvement over the earlier B<h2xs> as you can now
build multi-module packages.

=item COMPACT

For a module named "Foo::Bar::Baz" creates a base directory named
"Foo-Bar-Baz" instead of Foo/Bar/Baz. (Default off)

=item VERBOSE

Prints messages as it creates directories, writes files, etc. (Default off)

=item INTERACTIVE

Suppresses 'die' when something goes wrong.  Should only be used by interactive
scripts like L<modulemaker>. (Default off)

=item PERMISSIONS

Used to create new directories.  (Default is 0755, group and world can not write)

=item USAGE_MESSAGE

Message given when the module 'die's.  Scripts should set this to the same string it
would print if the user asked for help (often with a -h flag).

=item NEED_POD

Include POD section in modules. (Default is on)

=item NEED_NEW_METHOD

Include a simple 'new' method in the object oriented module.  (Default is on)

=item CHANGES_IN_POD

Don't include a 'Changes' file and add a HISTORY section to the POD. (Default is off).

=back

=cut

################################################## subroutine header end ##

sub new
{
	my ($class, %parameters) = @_;

	my $self = bless (default_values (), ref ($class) || $class);

	foreach my $param (keys %parameters) {
		if (ref ($parameters{$param}) eq 'HASH') {
			foreach (keys (%{$parameters{$param}})) {
				$self->{$param}{$_} = $parameters{$param}{$_};
			}
		} else {
			$self->{$param} = $parameters{$param};
		}
	}

	$self->set_author_data ();
	$self->set_dates ();
	$self->initialize_license ();

	$self->{MANIFEST} = ['MANIFEST'];

	return ($self);
}

################################################ subroutine header begin ##

=head2 default_values

 Usage     : $self->default_values ()
 Purpose   : Defaults for 'new'.
 Returns   : A hash of defaults as the basis for 'new'.
 Argument  : n/a
 Throws    : n/a
 Comments  : 

See Also   : 

=cut

################################################## subroutine header end ##

sub default_values
{
	my %defaults = (
					LICENSE				=> 'perl',
					VERSION				=> 0.01,
					ABSTRACT			=> '',
					AUTHOR				=>
					   {
						ORGANIZATION	=> 'XYZ Corp.',
						WEBSITE			=> 'http://a.galaxy.far.far.away/modules',
						EMAIL			=> 'a.u.thor@a.galaxy.far.far.away',
						NAME			=> 'A. U. Thor',
					   },
					BUILD_SYSTEM		=> 'ExtUtils::MakeMaker',
					COMPACT				=> 0,
					VERBOSE				=> 0,
					INTERACTIVE			=> 0,
					NEED_POD			=> 1,
					NEED_NEW_METHOD		=> 1,
					CHANGES_IN_POD		=> 0,

					PERMISSIONS			=> 0755,
				   );

$defaults{USAGE_MESSAGE} = <<ENDOFUSAGE;

There were problems with your data supplied to ExtUtils::ModuleMaker.
Please fix the problems listed above and try again.

ENDOFUSAGE

	return (\%defaults);
}

################################################ subroutine header begin ##

=head2 verify_values

 Usage     : $self->verify_values ()
 Purpose   : Verify module values are valid and complete.
 Returns   : Error message if there is a problem
 Argument  : n/a
 Throws    : Will die with a death_message if errors and not interactive.
 Comments  : 

See Also   : 

=cut

################################################## subroutine header end ##

sub verify_values
{
	my ($self) = @_;
	my @errors;

	push (@errors, 'NAME is required')
		unless ($self->{NAME});
	push (@errors, 'ABSTRACTs are limited to 44 characters')
		if (length ($self->{ABSTRACT}) > 44);
	push (@errors, 'CPAN IDS are 3-9 characters')
		if ((exists ($self->{AUTHOR}{CPANID})) &&
			($self->{AUTHOR}{CPANID}!~ m/^\w{3,9}$/));
	push (@errors, 'EMAIL addresses need to have an at sign')
		if ($self->{AUTHOR}{EMAIL}!~ m/.*\@.*/);
	push (@errors, 'WEBSITEs should start with an "http:" or "https:"')
		if ($self->{AUTHOR}{WEBSITE}!~ m/https?:\/\/.*/);
	push (@errors, 'LICENSE is not recognized"')
		unless (Verify_Local_License	($self->{LICENSE}) ||
				Verify_Standard_License	($self->{LICENSE}));

	return () unless (@errors);
	$self->death_message (@errors);
}

################################################ subroutine header begin ##
################################################## subroutine header end ##

sub complete_build
{
	my $self = shift;

	$self->verify_values ();

	$self->Create_Base_Directory ();
	$self->Check_Dir (map { "$self->{Base_Dir}/$_" } qw (lib t scripts));

	$self->print_file ('LICENSE',		$self->{LicenseParts}{LICENSETEXT});
	$self->print_file ('README',		$self->FileText_README () );
	$self->print_file ('Todo',			$self->FileText_ToDo ());

	unless ($self->{CHANGES_IN_POD}) {
		$self->print_file ('Changes',	$self->FileText_Changes ());
	}

	my $ct = 1;
	foreach my $module ($self, @{$self->{EXTRA_MODULES}}) {
		$self->generate_pm_file ($module);
		my $testfile = sprintf ("t/%03d_load.t", $ct);
		$self->print_file ($testfile,	$self->FileText_Test ($testfile, $module));
		$ct++;
	}

	#Makefile must be created after generate_pm_file which sets $self->{FILE}
	if ($self->{BUILD_SYSTEM} eq 'ExtUtils::MakeMaker') {
		$self->print_file ('Makefile.PL', $self->FileText_Makefile ());
	} else {
		$self->print_file ('Build.PL', $self->FileText_Buildfile ());
		if ($self->{BUILD_SYSTEM} eq 'Module::Build and proxy Makefile.PL') {
			$self->print_file ('Makefile.PL', $self->FileText_Proxy_Makefile ());
		}
	}




	$self->print_file ('MANIFEST', join ("\n", @{$self->{MANIFEST}}));
}

################################################ subroutine header begin ##
################################################## subroutine header end ##

sub generate_pm_file
{
	my ($self, $module) = @_;

	$self->Create_PM_Basics ($module);

	my $page = $self->Block_Begin ($module) .

			   (($self->module_value ($module, 'NEED_POD'))
				? $self->Block_Module_Header ($module)
				: () ) .

			   (( ($self->module_value ($module, 'NEED_POD')) &&
				  ($self->module_value ($module, 'NEED_NEW_METHOD')) )
				? $self->Block_Subroutine_Header ($module)
				: () ) .

			   (($self->module_value ($module, 'NEED_NEW_METHOD'))
				? $self->Block_New_Method ($module)
				: () ) .

			   $self->Block_Final_One ($module);

	$self->print_file ($module->{FILE}, $page );
}

########################################### main pod documentation begin ##

=head1 PRIVATE METHODS

Each private function/method is described here.
These methods and functions are considered private and are intended for
internal use by this module. They are B<not> considered part of the public
interface and are described here for documentation purposes.

If you choose to make a subclass of this module to customize ModuleMaker
for your environment you may need to replace some or all of these functions
to get what you need.  But as a general rule programs should not be using them
directly.

=cut

############################################# main pod documentation end ##


################################################ subroutine header begin ##

=head2 sample_function

 Usage     : How to use this function/method
 Purpose   : What it does
 Returns   : What it returns
 Argument  : What it wants to know
 Throws    : Exceptions and other anomolies
 Comments  : This is a sample subroutine header.
           : It is polite to include more pod and fewer comments.

See Also   : 

=cut

################################################## subroutine header end ##

sub set_dates
{
	my $self = shift;
	$self->{year} = (localtime)[5] + 1900;
	$self->{timestamp} = scalar localtime;
	$self->{COPYRIGHT_YEAR} ||= $self->{year};
}

sub set_author_data
{
	my ($self) = @_;

	my $p_author = $self->{AUTHOR};
	$p_author->{COMPOSITE} = ("\t" .
							  join ("\n\t",
									$p_author->{NAME},
									($p_author->{CPANID})
									? "CPAN ID: $p_author->{CPANID}" : (),
									$p_author->{EMAIL},
									$p_author->{WEBSITE},
								   ),
							 );
}

################################################ subroutine header begin ##

=head2 Create_Base_Directory

 Usage     : 
 Purpose   :
             Create the directory where all the files will be created.
 Returns   :
             $DIR = directory name where the files will live
 Argument  :
             $package_name = name of module separated by '::'
 Throws    : 
 Comments  : 

See Also   : Check_Dir

=cut

################################################## subroutine header end ##

sub Create_Base_Directory
{
	my $self = shift;

	$self->{Base_Dir} = join (($self->{COMPACT}) ? '-' : '/',
							  split (/::|'/, $self->{NAME}));
	$self->Check_Dir ($self->{Base_Dir});
}

################################################ subroutine header begin ##
################################################## subroutine header end ##

sub Create_PM_Basics
{
	my ($self, $module) = @_;
	my @layers = split (/::|'/, $module->{NAME});
	my $file = pop (@layers);
	my $dir = join ('/', 'lib', @layers);

	$self->Check_Dir ("$self->{Base_Dir}/$dir");
	$module->{FILE} = "$dir/$file.pm";
}

################################################ subroutine header begin ##
################################################## subroutine header end ##

sub initialize_license
{
	my ($self) = @_;

	$self->{LICENSE} = lc ($self->{LICENSE});

	my $license_function = Get_Local_License	($self->{LICENSE}) ||
						   Get_Standard_License	($self->{LICENSE});

	if (ref ($license_function) eq 'CODE') {
		$self->{LicenseParts} = $license_function->();

		$self->{LicenseParts}{LICENSETEXT} =~ s/###year###/$self->{COPYRIGHT_YEAR}/ig;
		$self->{LicenseParts}{LICENSETEXT} =~ s/###owner###/$self->{AUTHOR}{NAME}/ig;
		$self->{LicenseParts}{LICENSETEXT} =~ s/###organization###/$self->{AUTHOR}{ORGANIZATION}/ig;
	}

}

###########################################################################
###########################################################################
###########################################################################
###########################################################################

################################################ subroutine header begin ##
################################################## subroutine header end ##

sub get_attributes
{
	my $self = shift;
	local $_;
	return map { $self->{$_} } @_;
}

################################################ subroutine header begin ##
################################################## subroutine header end ##

sub module_value
{
	my ($self, $module, @keys) = @_;

	if (scalar (@keys) == 1) {
		return ($module->{$keys[0]}) if (exists (($module->{$keys[0]})));
		return ($self->{$keys[0]});
	} elsif (scalar (@keys) == 2) {
		return ($module->{$keys[0]}{$keys[1]}) if (exists (($module->{$keys[0]}{$keys[1]})));
		return ($self->{$keys[0]}{$keys[1]});
	} else {
		return ();
	}
}

################################################ subroutine header begin ##
################################################## subroutine header end ##

sub print_file
{
	my ($self, $filename, $page) = @_;

	push (@{$self->{MANIFEST}}, $filename) unless ($filename eq 'MANIFEST');
	$self->log_message ("writing file '$filename'");

	open (FILE, ">$self->{Base_Dir}/$filename") or $self->death_message ("Could not write '$filename', $!");
	print FILE ($page);
	close FILE;
}

################################################ subroutine header begin ##

=head2 Check_Dir

 Usage     :
             Check_Dir ($dir, $MODE);
 Purpose   :
             Creates a directory with the correct mode if needed.
 Returns   : n/a
 Argument  :
             $dir = directory name
             $MODE = mode of directory (e.g. 0777, 0755)
 Throws    : 
 Comments  : 

See Also   : 

=cut

################################################## subroutine header end ##

sub Check_Dir
{
	my $self = shift;

	return mkpath (\@_, $self->{VERBOSE}, $self->{PERMISSIONS});
	$self->death_message ("Can't create a directory: $!");
}

################################################ subroutine header begin ##
################################################## subroutine header end ##

sub death_message
{
	my $self = shift;

	die (join "\n", @_, '', $self->{USAGE_MESSAGE}) unless $self->{INTERACTIVE};
	print (join "\n", 'Oops, there are the following errors:', @_, '', '');
}

################################################ subroutine header begin ##
################################################## subroutine header end ##

sub log_message
{
	my ($self, $message) = @_;
	print "$message\n" if $self->{VERBOSE};
}

###########################################################################
###########################################################################
###########################################################################
###########################################################################

################################################ subroutine header begin ##
################################################## subroutine header end ##

sub pod_section
{
	my ($self, $heading, $content) = @_;

my $string = <<ENDOFSTUFF;

 ====head1 $heading

$content
ENDOFSTUFF

	$string =~ s/\n ====/\n=/g;
	return ($string);
}

################################################ subroutine header begin ##
################################################## subroutine header end ##

sub pod_wrapper
{
	my ($self, $section) = @_;

my $head = <<EOFBLOCK;

########################################### main pod documentation begin ##
# Below is the stub of documentation for your module. You better edit it!

EOFBLOCK

my $tail = <<EOFBLOCK;

 ====cut

############################################# main pod documentation end ##

EOFBLOCK

	$tail =~ s/\n ====/\n=/g;
	return (join ('', $head, $section, $tail));
}

###########################################################################
###########################################################################
###########################################################################
###########################################################################

################################################ subroutine header begin ##

=head2 Block_Begin

 Usage     : $self->Block_Begin ()
 Purpose   : Build part of a module pm file
 Returns   : Part of the file being built
 Argument  : $module: pointer to the module being built, for the primary
                      module it is a pointer to $self
 Throws    : n/a
 Comments  : This method is a likely candidate for alteration in a subclass

See Also   : 

=cut

################################################## subroutine header end ##

sub Block_Begin
{
	my ($self, $module) = @_;

	my $version = $self->module_value ($module, 'VERSION');

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

################################################ subroutine header begin ##

=head2 Block_Begin_BareBones

 Usage     : $self->Block_Begin_BareBones ()
 Purpose   : Build part of a module pm file
 Returns   : Part of the file being built
 Argument  : $module: pointer to the module being built, for the primary
                      module it is a pointer to $self
 Throws    : n/a
 Comments  : This method is a likely candidate for alteration in a subclass

See Also   : 

=cut

################################################## subroutine header end ##

sub Block_Begin_BareBones
{
	my ($self, $module) = @_;

	my $version = $self->module_value ($module, 'VERSION');

my $string = <<EOFBLOCK;

package $module->{NAME};
use strict;

BEGIN {
	use vars qw (\$VERSION);
	\$VERSION     = $version;
}

EOFBLOCK

	return ($string);
}

################################################ subroutine header begin ##

=head2 Block_New_Method

 Usage     : $self->Block_New_Method ()
 Purpose   : Build part of a module pm file
 Returns   : Part of the file being built
 Argument  : $module: pointer to the module being built, for the primary
                      module it is a pointer to $self
 Throws    : n/a
 Comments  : This method is a likely candidate for alteration in a subclass

See Also   : 

=cut

################################################## subroutine header end ##

sub Block_New_Method
{
	my ($self, $module) = @_;

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

################################################ subroutine header begin ##

=head2 Block_Module_Header

 Usage     : $self->Block_Module_Header ()
 Purpose   : Build part of a module pm file
 Returns   : Part of the file being built
 Argument  : $module: pointer to the module being built, for the primary
                      module it is a pointer to $self
 Throws    : n/a
 Comments  : This method is a likely candidate for alteration in a subclass

See Also   : 

=cut

################################################## subroutine header end ##

sub Block_Module_Header
{
	my ($self, $module) = @_;

my $description = <<EOFBLOCK;
Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.
EOFBLOCK

	my $string = join
		('',
		 $self->pod_section (NAME =>
								$self->module_value ($module, 'NAME') . ' - ' .
								$self->module_value ($module, 'ABSTRACT')
							),
		 $self->pod_section (SYNOPSIS =>
								'  use ' . $self->module_value ($module, 'NAME') .
								"\n  blah blah blah\n"
							),
		 $self->pod_section (DESCRIPTION => $description
							),
		 $self->pod_section (USAGE => ''
							),
		 $self->pod_section (BUGS => ''
							),
		 $self->pod_section (SUPPORT => ''
							),
		 (($self->{CHANGES_IN_POD})
		  ?
			 $self->pod_section (HISTORY => $self->FileText_Changes ('only pod')
								)
		  : ()
		 ),
		 $self->pod_section (AUTHOR =>
								$self->module_value ($module, 'AUTHOR', 'COMPOSITE')
							),
		 $self->pod_section (COPYRIGHT =>
								$self->module_value ($module, 'LicenseParts', 'COPYRIGHT')
							),
		 $self->pod_section ('SEE ALSO' =>
								'perl(1).'
							),
		);

	return ($self->pod_wrapper ($string));
}

################################################ subroutine header begin ##

=head2 Block_Subroutine_Header

 Usage     : $self->Block_Subroutine_Header ()
 Purpose   : Build part of a module pm file
 Returns   : Part of the file being built
 Argument  : $module: pointer to the module being built, for the primary
                      module it is a pointer to $self
 Throws    : n/a
 Comments  : This method is a likely candidate for alteration in a subclass

See Also   : 

=cut

################################################## subroutine header end ##

sub Block_Subroutine_Header
{
	my ($self, $module) = @_;

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

################################################ subroutine header begin ##

=head2 Block_Final_One

 Usage     : $self->Block_Final_One ()
 Purpose   : Make module return a true value
 Returns   : Part of the file being built
 Argument  : $module: pointer to the module being built, for the primary
                      module it is a pointer to $self
 Throws    : n/a
 Comments  : This method is a likely candidate for alteration in a subclass

See Also   : 

=cut

################################################## subroutine header end ##

sub Block_Final_One
{
	my ($self, $module) = @_;

my $string = <<EOFBLOCK;

1; #this line is important and will help the module return a true value
__END__

EOFBLOCK

	return ($string);
}

################################################ subroutine header begin ##

=head2 FileText_README

 Usage     : $self->FileText_README ()
 Purpose   : Build a supporting file
 Returns   : Text of the file being built
 Argument  : n/a
 Throws    : n/a
 Comments  : This method is a likely candidate for alteration in a subclass

See Also   : 

=cut

################################################## subroutine header end ##

sub FileText_README
{
	my ($self) = @_;




	my $build_instructions;
	if ($self->{BUILD_SYSTEM} eq 'ExtUtils::MakeMaker') {

		$build_instructions = <<EOF;
perl Makefile.PL
make
make test
make install
EOF

	} else {

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

################################################ subroutine header begin ##

=head2 FileText_Changes

 Usage     : $self->FileText_Changes ()
 Purpose   : Build a supporting file
 Returns   : Text of the file being built
 Argument  : $only_in_pod:  True value to get only a HISTORY section for POD
                            False value to get whole Changes file
 Throws    : n/a
 Comments  : This method is a likely candidate for alteration in a subclass

See Also   : 

=cut

################################################## subroutine header end ##

sub FileText_Changes
{
	my ($self, $only_in_pod) = @_;

	my $page;

	unless ($only_in_pod) {
$page = <<EOF;
Revision history for Perl module $self->{NAME}

$self->{VERSION} $self->{timestamp}
	- original version; created by ExtUtils::ModuleMaker $VERSION


EOF
	} else {
$page = <<EOF;
$self->{VERSION} $self->{timestamp}
	- original version; created by ExtUtils::ModuleMaker $VERSION
EOF
	}

	return ($page);
}

################################################ subroutine header begin ##

=head2 FileText_ToDo

 Usage     : $self->FileText_ToDo ()
 Purpose   : Build a supporting file
 Returns   : Text of the file being built
 Argument  : n/a
 Throws    : n/a
 Comments  : This method is a likely candidate for alteration in a subclass

See Also   : 

=cut

################################################## subroutine header end ##

sub FileText_ToDo
{
	my ($self) = @_;
	
my $page = <<EOF;
TODO list for Perl module $self->{NAME}

- Nothing yet


EOF

	return ($page);
}

################################################ subroutine header begin ##

=head2 FileText_Makefile

 Usage     : $self->FileText_Makefile ()
 Purpose   : Build a supporting file
 Returns   : Text of the file being built
 Argument  : n/a
 Throws    : n/a
 Comments  : This method is a likely candidate for alteration in a subclass

See Also   : 

=cut

################################################## subroutine header end ##

sub FileText_Makefile
{
	my ($self) = @_;
#	my $extras = join ("\n",
#					   map { "    $_ => '$self->{EXTRAMAKE}{$_}'," }
#					   keys %{$self->{EXTRAMAKE}}
#					  ) if ((exists $self->{EXTRAMAKE}) &&
#							(ref ($self->{EXTRAMAKE}) eq 'hash'));
	
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
#	($] ge '5.005')
#	 ? (AUTHOR   => '$self->{AUTHOR}{NAME} ($self->{AUTHOR}{EMAIL})',
#		ABSTRACT => '$self->{ABSTRACT}',
#	   )
#	 : (),

	return ($page);
}

################################################ subroutine header begin ##

=head2 FileText_Buildfile

 Usage     : $self->FileText_Buildfile ()
 Purpose   : Build a supporting file
 Returns   : Text of the file being built
 Argument  : n/a
 Throws    : n/a
 Comments  : This method is a likely candidate for alteration in a subclass

See Also   :

=cut

################################################## subroutine header end ##

sub FileText_Buildfile
{
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

################################################ subroutine header begin ##

=head2 FileText_Proxy_Makefile

 Usage     : $self->FileText_Proxy_Makefile ()
 Purpose   : Build a supporting file
 Returns   : Text of the file being built
 Argument  : n/a
 Throws    : n/a
 Comments  : This method is a likely candidate for alteration in a subclass

See Also   :

=cut

################################################## subroutine header end ##

sub FileText_Proxy_Makefile
{
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

################################################ subroutine header begin ##

=head2 FileText_Test

 Usage     : $self->FileText_Test ()
 Purpose   : Build a supporting file
 Returns   : Text of the file being built
 Argument  : n/a
 Throws    : n/a
 Comments  : This method is a likely candidate for alteration in a subclass
             Will make a test with or without a checking for method new.

See Also   : 

=cut

################################################## subroutine header end ##

sub FileText_Test
{
	my ($self, $testnum, $module) = @_;

	my $name	= $self->module_value ($module, 'NAME');
	my $neednew	= $self->module_value ($module, 'NEED_NEW_METHOD');

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

	} else {

$page = <<EOF;
# -*- perl -*-

# $testnum - check module loading and create testing directory

use Test::More tests => 1;

BEGIN { use_ok( '$name' ); }


EOF

	}

	return ($page);
}

###########################################################################
###########################################################################
###########################################################################
###########################################################################


 
################################################ subroutine header begin ##

=head2 Quick_Module

 Usage     :
             perl -MExtUtils::ModuleMaker -e "Quick_Module ('Sample::Module')"
 or
             use ExtUtils::ModuleMaker;
             Quick_Module ('Sample::Module');

 Purpose   : Creates a Module.pm with supporing files
 Returns   : n/a
 Argument  : A name for the module, like 'Module' or 'Sample::Module'
 Throws    : 
 Comments  : More closely mimics h2xs behavior than Generate_Module_Files.
           : Included to allow simple creation from a command line.
           : This function is deprecated and will disappear forever soon.

See Also   : Generate_Module_Files

=cut

################################################## subroutine header end ##

sub Quick_Module
{
	&Generate_Module_Files (NAME => $_[0]);
}

################################################ subroutine header begin ##

=head2 Generate_Module_Files

 Usage     : How to use this function/method
 Purpose   : Creates one or more modules with supporing files
 Returns   : n/a
 Argument  : A hash with the information for the new module(s)
 Throws    : 
 Comments  : This function is deprecated and will disappear forever soon.

=cut

################################################## subroutine header end ##

sub Generate_Module_Files
{
	my $MOD = ExtUtils::ModuleMaker->new (@_);
	$MOD->complete_build ();
}


###########################################################################
###########################################################################
###########################################################################
###########################################################################

1; #this line is important and will help the module return a true value
__END__



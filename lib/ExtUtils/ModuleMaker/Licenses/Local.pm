
package ExtUtils::ModuleMaker::Licenses::Local;
use strict;

BEGIN {
	use Exporter ();
	use vars qw ($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
	$VERSION     = 0.32;
	@ISA         = qw (Exporter);
	#Give a hoot don't pollute, do not export more than needed by default
	@EXPORT      = qw (&Get_Local_License &Verify_Local_License);
	@EXPORT_OK   = qw ();
	%EXPORT_TAGS = ();
}

########################################### main pod documentation begin ##
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

ExtUtils::ModuleMaker::Licenses::Local - Templates for the module's License/Copyright

=head1 SYNOPSIS

  use ExtUtils::ModuleMaker::Local::Licenses;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.

=head1 USAGE

=head1 BUGS

=head1 SUPPORT

=head1 AUTHOR

	R. Geoffrey Avery
	CPAN ID: RGEOFFREY
	modulemaker@PlatypiVentures.com
	http://www.PlatypiVentures.com/perl/modules/ModuleMaker.shtml

=head1 COPYRIGHT

Copyright (c) 2002 R. Geoffrey Avery. All rights reserved.
This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=head1 SEE ALSO

perl(1).

=head1 PUBLIC METHODS

Each public function/method is described here.
These are how you should interact with this module.

=cut

############################################# main pod documentation end ##

my %licenses =
			(
			 looselips		=> { function => \&License_LooseLips,
								 fullname => 'Loose Lips License (1.0)'
							   },
			);

sub Get_Local_License
{
	my ($choice) = @_;

	$choice = lc ($choice);
	return ($licenses{$choice}{function}) if (exists $licenses{$choice});
	return ();
}

sub Verify_Local_License
{
	my ($choice) = @_;
	return (exists $licenses{lc ($choice)});
}

sub interact
{
	my ($class) = @_;
	return (bless ({map { ($licenses{$_}{fullname})
							? ($_ => $licenses{$_}{fullname})
							: ()
						} keys (%licenses)
				   }, ref ($class) || $class));
}

sub Display_License
{
	my ($self, $choice) = @_;
	my $p_license = Get_Local_License ($choice);
	return (join ("\n\n",
				  "=====================================================================",
				  "=====================================================================",
				  $p_license->{LICENSETEXT},
				  "=====================================================================",
				  "=====================================================================",
				  $p_license->{COPYRIGHT},
				  "=====================================================================",
				  "=====================================================================",
				 ));
}

################################################ subroutine header begin ##

=head2 License_LooseLips

 Purpose   : Get the copyright pod text and LICENSE file text for this license

=cut

################################################## subroutine header end ##

sub License_LooseLips
{
	my %license;

$license{COPYRIGHT} = <<EOFCOPYRIGHT;
This program is licensed under the...

	Loose Lips License

The full text of the license can be found in the
LICENSE file included with this module.
EOFCOPYRIGHT

$license{LICENSETEXT} = <<EOFLICENSETEXT;
Loose Lips License
Version 1.0

Copyright (c) ###year### ###organization###. All rights reserved.

This software is the intellectual property of ###organization###.  Its
contents are a trade secret and are not to be shared with anyone outside
the organization.

Remember, "Loose lips sink ships."
EOFLICENSETEXT

	return (\%license);
}

1; #this line is important and will help the module return a true value
__END__



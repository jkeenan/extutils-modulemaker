package ExtUtils::ModuleMaker::SecondStyle;
use strict;
local $^W = 1;

use ExtUtils::ModuleMaker::Licenses::Standard;
use ExtUtils::ModuleMaker::Licenses::Local;
use ExtUtils::ModuleMaker;

BEGIN {
	use Exporter ();
	use vars qw ( @ISA );
#	$VERSION     : taken from lib/ExtUtils/ModuleMaker.pm
	@ISA         = qw (Exporter ExtUtils::ModuleMaker);
}

########################################### main pod documentation begin ##
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

ExtUtils::ModuleMaker::SecondStyle - Demonstation of alternate style/templates

=head1 SYNOPSIS

  use ExtUtils::ModuleMaker::Baseclass;
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

# Public methods and functions go here. 



########################################### main pod documentation begin ##

=head1 PRIVATE METHODS

Each private function/method is described here.
These methods and functions are considered private and are intended for
internal use by this module. They are B<not> considered part of the public
interface and are described here for documentation purposes only.

=cut

############################################# main pod documentation end ##


# Private methods and functions go here.

################################################ subroutine header begin ##
################################################## subroutine header end ##

################################################ subroutine header begin ##
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

	$self->initialize_license ();
	$self->set_author_data ();
	$self->set_dates ();

	$self->{MANIFEST} = ['MANIFEST'];

	return ($self);
}

sub default_values
{
	my $p_defaults = ExtUtils::ModuleMaker::default_values();

	$p_defaults->{LICENSE}	= 'gpl';
	$p_defaults->{VERSION}	= 0.02;
	$p_defaults->{AUTHOR}{ORGANIZATION}	= 'ABC Corp.';
	$p_defaults->{AUTHOR}{WEBSITE}		= 'http://long.long.ago/modules';
	$p_defaults->{AUTHOR}{EMAIL}		= 'a.u.thor@long.long.ago';
	$p_defaults->{AUTHOR}{NAME}			= 'A. U. Thor';

	return ($p_defaults);
}

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

sub Block_Begin
{
	my ($self, $module) = @_;

	my $version = $self->module_value ($module, 'VERSION');

my $string = <<EOFBLOCK;

package $module->{NAME};
use strict;

BEGIN {
	use Exporter ();
	our (\$VERSION \@ISA \@EXPORT \@EXPORT_OK \%EXPORT_TAGS);
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




1; #this line is important and will help the module return a true value
__END__



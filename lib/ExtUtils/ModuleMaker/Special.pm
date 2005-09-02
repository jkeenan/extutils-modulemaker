package ExtUtils::ModuleMaker::Special;
use strict;
local $^W = 1;
BEGIN {
    use ExtUtils::ModuleMaker::Utility qw( 
        _preexists_mmkr_directory
        _make_mmkr_directory
    );
    my $mmkr_dir_ref =  _preexists_mmkr_directory();
    my $mmkr_dir = _make_mmkr_directory( $mmkr_dir_ref );
    unshift @INC, $mmkr_dir;
}
BEGIN {
    use base qw(
        ExtUtils::ModuleMaker::Personal::Defaults
        ExtUtils::ModuleMaker::StandardText
        ExtUtils::ModuleMaker::Regular
    );
    use vars qw ( $VERSION ); 
    $VERSION = '0.36_16';
};
use Carp;

sub new {
    my $class = shift;

    my $self = ref($class) ? bless( {}, ref($class) )
                           : bless( {}, $class );

    # multi-stage initialization of EU::MM object
    
    # 1. 

    # 2.  Populate object with default values.
    my $defaults_ref;
    $defaults_ref = $self->default_values();
    foreach my $def ( keys %{$defaults_ref} ) {
        $self->{$def} = $defaults_ref->{$def};
    }

    # 3.  Pull in arguments supplied to constructor.
    my @arglist = @_;
    croak "Must be hash or balanced list of key-value pairs: $!"
        if (@arglist % 2);
    my %parameters = @arglist;

    # 4.  Process key-value pairs supplied as arguments to new() either
    # from user-written program or from modulemaker utility.
    # These override default values (or may provide additional elements).
    foreach my $param ( keys %parameters ) {
        $self->{$param} = $parameters{$param};
    }

    # 5.  Initialize keys set from information supplied above, system
    # info or EU::MM itself.
    $self->set_author_composite();
    $self->set_dates();
    $self->{eumm_version} = $VERSION;
    $self->{MANIFEST} = ['MANIFEST'];

    # 6.  Validate values supplied so far to weed out most likely errors
    $self->validate_values();

    # 7.  Initialize keys set from EU::MM::Licenses::Local or
    # EU::MM::Licenses::Standard
    $self->initialize_license();

    return $self;
}

1;

#################### DOCUMENTATION ####################

=head1 NAME

ExtUtils::ModuleMaker::Special - 

=head1 DESCRIPTION

This package holds the basic formulation of ExtUtils::ModuleMaker.
ExtUtils::ModuleMaker functions as a factory class -- "a class that 
generates instances of other classes, choosing which class to build 
on the basis of run-time information." (Damian Conway, Perlmonks, 
September 1, 2005)  ExtUtils::ModuleMaker::Regular holds the 'default'
settings for attributes provided to the constructor as well as the 'default'
way of using ExtUtils::ModuleMaker to build directories and files for a proper
Perl distribution.  All ExtUtils::ModuleMaker::Regular methods, as well as
those of modules from which it itself inherits, are available in
ExtUtils::ModuleMaker but may be overridden by user-supplied methods.

See the documentation for ExtUtils::ModuleMaker for a description of publicly
available methods.

=head1 AUTHOR

James E. Keenan (jkeenan [at] cpan [dot] org).

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



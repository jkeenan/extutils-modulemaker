package ExtUtils::ModuleMaker::Regular;
use strict;
local $^W = 1;
BEGIN {
    use ExtUtils::ModuleMaker::Utility qw( 
        _preexists_mmkr_directory
        _make_mmkr_directory
    );
    use base qw(
        ExtUtils::ModuleMaker::Defaults
        ExtUtils::ModuleMaker::StandardText
    );
    use vars qw ( $VERSION ); 
    $VERSION = '0.36_16';
};
use Carp;
use File::Path;
use File::Spec;
# use Data::Dumper;

sub new {
    my $class = shift;

    my $self = ref($class) ? bless( {}, ref($class) )
                           : bless( {}, $class );

    # multi-stage initialization of EU::MM object
    
    # 1. Determine if there already exists on system a directory capable of
    # holding user ExtUtils::ModuleMaker::Personal::Defaults.  The name of
    # such a directory and whether it exists at THIS point are stored in an
    # array, a reference to which is the return value of
    # _preexists_mmkr_directory and which is then stored in the object.
    # NOTE:  If the directory does not yet exists, it is not automatically
    # created.
    $self->{mmkr_dir_ref} =  _preexists_mmkr_directory();

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
sub complete_build {
    my $self = shift;

    $self->create_base_directory();
    $self->check_dir( map { "$self->{Base_Dir}/$_" } qw (lib t scripts) );

    $self->print_file( 'LICENSE', $self->{LicenseParts}{LICENSETEXT} );
    $self->print_file( 'README',  $self->text_README() );
    $self->print_file( 'Todo',    $self->text_ToDo() );

    unless ( $self->{CHANGES_IN_POD} ) {
        $self->print_file( 'Changes', $self->text_Changes() );
    }

    my $ct = 1;
    foreach my $module ( $self, @{ $self->{EXTRA_MODULES} } ) {
        $self->generate_pm_file($module);
        my $testfile = sprintf( "t/%03d_load.t", $ct );
        $self->print_file( $testfile,
            $self->text_test( $testfile, $module ) );
        $ct++;
    }

    #Makefile must be created after generate_pm_file which sets $self->{FILE}
    if ( $self->{BUILD_SYSTEM} eq 'ExtUtils::MakeMaker' ) {
        $self->print_file( 'Makefile.PL', $self->text_Makefile() );
    }
    else {
        $self->print_file( 'Build.PL', $self->text_Buildfile() );
        if ( $self->{BUILD_SYSTEM} eq 'Module::Build and proxy Makefile.PL' 
         or  $self->{BUILD_SYSTEM} eq 'Module::Build and Proxy') {
            $self->print_file( 'Makefile.PL',
                $self->text_proxy_makefile() );
        }
    }

    $self->print_file( 'MANIFEST', join( "\n", @{ $self->{MANIFEST} } ) );
    $self->make_selections_defaults() if $self->{SAVE_AS_DEFAULTS};
    return 1;
}

sub dump_keys {
    my $self = shift;
    my %keys_to_be_shown = map {$_, 1} @_;
    require Data::Dumper;
    my ($k, $v, %retry);
    while ( ($k, $v) = each %{$self} ) {
        $retry{$k} = $v if $keys_to_be_shown{$k};
    }
    my $d = Data::Dumper->new( [\%retry] );
    return $d->Dump;
}

sub dump_keys_except {
    my $self = shift;
    my %keys_not_shown = map {$_, 1} @_;
    require Data::Dumper;
    my ($k, $v, %retry);
    while ( ($k, $v) = each %{$self} ) {
        $retry{$k} = $v unless $keys_not_shown{$k};
    }
    my $d = Data::Dumper->new( [\%retry] );
    return $d->Dump;
}

sub get_license {
    my $self = shift;
    return (join ("\n\n",
        "=====================================================================",
        "=====================================================================",
        $self->{LicenseParts}{LICENSETEXT},
        "=====================================================================",
        "=====================================================================",
        $self->{LicenseParts}{COPYRIGHT},
        "=====================================================================",
        "=====================================================================",
    ));
}

sub make_selections_defaults {
    my $self = shift;
    my %selections = %{$self};
    my $topfile = <<'END_TOPFILE';
package ExtUtils::ModuleMaker::Personal::Defaults;
use strict;

my %default_values = (
END_TOPFILE
    
my @keys_needed = qw(
    LICENSE
    VERSION
    AUTHOR
    CPANID
    ORGANIZATION
    WEBSITE
    EMAIL
    BUILD_SYSTEM
    COMPACT
    VERBOSE
    INTERACTIVE
    NEED_POD
    NEED_NEW_METHOD
    CHANGES_IN_POD
    PERMISSIONS
    USAGE_MESSAGE
);

my $kvpairs;
foreach my $k (@keys_needed) {
    $kvpairs .=
        (' ' x 8) . (sprintf '%-16s', $k) . '=> q{' . $selections{$k} .  "},\n";
}
$kvpairs .= (' ' x 8) . (sprintf '%-16s', 'ABSTRACT') . 
    '=> q{Module abstract (<= 44 characters) goes here}' . "\n";

    my $bottomfile = <<'END_BOTTOMFILE';
);

sub default_values {
    my $self = shift;
    return { %default_values };
}

1;

END_BOTTOMFILE

    my $output =  $topfile . $kvpairs . $bottomfile;

    my $mmkr_dir = _make_mmkr_directory($self->{mmkr_dir_ref});
    my $pers_path = "ExtUtils/ModuleMaker/Personal";
    my $full_dir = File::Spec->catdir($mmkr_dir, $pers_path);
    if (! -d $full_dir) {
        mkpath( $full_dir );
        if ($@) {
            croak "Unable to make directory for placement of personal defaults file: $!"; };
    }
    my $pers_file = "Defaults.pm";
    my $pers_full = "$full_dir/$pers_file";
    if (-f $pers_full ) {
        my $modtime = (stat($pers_full))[9];
        rename $pers_full,
               "$pers_full.$modtime"
            or croak "Unable to rename $pers_full: $!";
    }
    open my $fh, '>', $pers_full 
        or croak "Unable to open $pers_full for writing: $!";
    print $fh $output or croak "Unable to print $pers_full: $!";
    close $fh or croak "Unable to close $pers_full after writing: $!";
}
#################### DOCUMENTATION ####################

=head1 NAME

ExtUtils::ModuleMaker::Regular - Holds the regular methods for ExtUtils::ModuleMaker

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



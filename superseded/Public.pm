package ExtUtils::ModuleMaker::Public;
use strict;
local $^W = 1;
BEGIN {
    use vars qw( $VERSION @ISA ); 
    $VERSION = '0.37_01';
    use base qw(
        ExtUtils::ModuleMaker::StandardText
    );
};
#        ExtUtils::ModuleMaker::Defaults
#        ExtUtils::ModuleMaker::Initializers
use ExtUtils::ModuleMaker::Utility qw( 
    _make_mmkr_directory
);
#    _preexists_mmkr_directory
use Carp;
use File::Path;
use File::Spec;
# use Data::Dumper;
use Cwd;

#################### PUBLICLY CALLABLE METHODS ####################

sub complete_build {
    my $self = shift;

    $self->create_base_directory();
    $self->check_dir( map { "$self->{Base_Dir}/$_" } qw (lib t scripts) );

    $self->print_file( 'LICENSE', $self->{LicenseParts}{LICENSETEXT} );
    $self->print_file( 'README',  $self->text_README() );
    $self->print_file( 'Todo',    $self->text_Todo() )
        if $self->text_Todo();

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

1;

#################### DOCUMENTATION ####################

=head1 NAME

ExtUtils::ModuleMaker::Public - Holds all public EU::MM methods except new()

=head1 DESCRIPTION

These methods are documented in ExtUtils::ModuleMaker.

=head1 AUTHOR

James E. Keenan (jkeenan [at] cpan [dot] org).

=cut


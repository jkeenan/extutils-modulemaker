package ExtUtils::ModuleMaker::Alt_no_scripts_dir;
use strict;
local $^W = 1;
use Carp;
use vars qw( @ISA );

sub complete_build {
    my $self = shift;

    if (defined $self->{ALT_BUILD}) {
        my $alt_build = $self->{ALT_BUILD};
        unless ($alt_build =~ /^ExtUtils::ModuleMaker::/) {
            $alt_build = q{ExtUtils::ModuleMaker::} . $alt_build;
        }
        eval "require $alt_build";
        if ($@) {
            croak "Unable to locate $alt_build for alternative methods: $!";
        } else {
            unshift @ISA, $alt_build;
        };
    }
    $self->create_base_directory();
    # no 'scripts' in line below -> no scripts/ will be created
    $self->check_dir( map { "$self->{Base_Dir}/$_" } qw ( lib t ) );

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

1;


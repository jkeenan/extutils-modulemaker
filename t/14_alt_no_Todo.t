# t/14_alt_no_Todo.t
use strict;
local $^W = 1;
use Test::More 
tests =>  33;
# qw(no_plan);
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'Cwd');
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
        _subclass_preparatory_tests
        _subclass_cleanup_tests
    )
);
use_ok( 'File::Copy' );
use Carp;

SKIP: {
    eval { require 5.006_001 };
    skip "tests require File::Temp, core with 5.6", 
        (33 - 4) if $@;
    use warnings;
    use_ok( 'File::Temp', qw| tempdir |);

    {   # Set:   Alt_no_Todo

        my $odir = cwd();
        my $prepref = _subclass_preparatory_tests($odir);

        my $persref         = $prepref->{persref};
        my %els1            = %{ $prepref->{initial_els_ref} };
        my $eumm_dir        = $prepref->{eumm_dir};
        my $mmkr_dir_ref    = $prepref->{mmkr_dir_ref};

        # real tests go here

        my $alt = 'Alt_no_Todo.pm';
        copy( "$prepref->{sourcedir}/$alt", "$eumm_dir/$alt")
            or die "Unable to copy $alt for testing: $!";
        ok(-f "$eumm_dir/$alt", "file copied for testing");

        my $testmod = 'Beta';
        my $mod;
        
        ok( $mod = ExtUtils::ModuleMaker->new( 
                NAME           => "Alpha::$testmod",
                COMPACT        => 1,
                ALT_BUILD      =>
                    q{ExtUtils::ModuleMaker::Alt_no_Todo},
            ),
            "call ExtUtils::ModuleMaker->new for Alpha-$testmod"
        );

        ok( $mod->complete_build(), 'call complete_build()' );

        ok( -d qq{Alpha-$testmod}, "compact top-level directory exists" );
        ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );
        ok( -d, "directory $_ exists" ) for ( qw/lib scripts t/);
        ok( -f, "file $_ exists" )
            for ( qw/Changes LICENSE Makefile.PL MANIFEST README/);
        ok(! -f "Todo", "Todo not created");
        ok( -f, "file $_ exists" )
            for ( "lib/Alpha/${testmod}.pm", "t/001_load.t" );

        unlink( "$eumm_dir/$alt" )
            or croak "Unable to unlink $alt for testing: $!";
        ok(! -f "$eumm_dir/$alt", "file $alt deleted after testing");

        # end of real tests

        _subclass_cleanup_tests( {
            persref         => $persref,
            eumm_dir        => $eumm_dir,
            initial_els_ref => \%els1,
            odir            => $odir,
            mmkr_dir_ref    => $mmkr_dir_ref,
        } );

    } # end of Set
} # end SKIP block



# t/04_compact.t
use strict;
use warnings;
use Carp;
use File::Spec;
use File::Temp qw(tempdir);
use Test::More tests =>  15;
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
    prepare_mockdirs
    basic_file_and_directory_tests
    license_text_test
) );

{
    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    #######################################################################

    my $mod;

    my @components = qw| Sample Module Foo |;
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    ok($mod  = ExtUtils::ModuleMaker->new
    			( 
    				NAME		=> $module_name,
    				COMPACT		=> 1,
    				LICENSE		=> 'looselips',
    			 ),
    	"call ExtUtils::ModuleMaker->new for $dist_name");
    	
    ok( $mod->complete_build(), 'call complete_build()' );

    basic_file_and_directory_tests($dist_name);
    license_text_test($dist_name, qr/Loose lips sink ships/);
}


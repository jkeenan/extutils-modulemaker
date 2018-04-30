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
}

sub basic_file_and_directory_tests {
    my $dist_name = shift;
    for my $f ( qw| Changes MANIFEST Makefile.PL LICENSE README | ) {
        my $ff = File::Spec->catfile($dist_name, $f);
        ok (-e $ff, "$ff exists");
    }
    for my $d ( qw| lib t | ) {
        my $dd = File::Spec->catdir($dist_name, $d);
        ok(-d $dd, "Directory '$dd' exists");
    }   

    my $filetext;
    {
        open my $FILE, '<', File::Spec->catfile($dist_name, 'LICENSE')
            or croak "Unable to open LICENSE for reading";
        $filetext = do {local $/; <$FILE>};
        close $FILE or croak "Unable to close LICENSE after reading";
    }

    ok($filetext =~ m/Loose lips sink ships/,
    	"correct LICENSE generated");
    return 1;
}

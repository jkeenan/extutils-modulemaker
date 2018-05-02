# t/81-opts.t
# tests of ExtUtils::ModuleMaker::Opts methods
use strict;
use warnings;
#use Carp;
#use Cwd;
#use File::Spec;
#use File::Temp qw(tempdir);
use Test::More;
#use_ok( 'IO::Capture::Stdout' );
#use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::Opts' );
#use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
#    prepare_mockdirs
#    basic_file_and_directory_tests
#    license_text_test
#    read_file_string
#    read_file_array
#    compact_build_tests
#) );
use Data::Dump qw( dd pp );

my ($eumm_package, $eumm_script, $opt);
$eumm_package = q{ExtUtils::ModuleMaker};
$eumm_script  = q{modulemaker};

{
    note("Case 1: Simplest possible use");

    my $name = 'Alpha::Beta';
    local @ARGV = ('-n' => $name, '-I' => 0);

    $opt = ExtUtils::ModuleMaker::Opts->new( $eumm_package, $eumm_script );
    ok(defined $opt, "ExtUtils::ModuleMaker::Opts returned defined value");
    isa_ok($opt, 'ExtUtils::ModuleMaker::Opts');
    dd($opt);
    
    my %stan = $opt->get_standard_options();
    is($stan{NAME}, $name, "NAME correctly set to $name");
}

done_testing();

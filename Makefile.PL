use ExtUtils::MakeMaker;
require 5.006001;

my $mm_ver = ExtUtils::MakeMaker->VERSION;

my @tests_confirmed = map { "t/$_" } qw(
    01_ini.t
    03_quick.t
    04_compact.t
    05_abstract.t
    06_build.t
    07_proxy.t
    10_standard_text.t
    12_make-defaults.t
    13_alt_block_new_method.t
    21_failsafe.t
    22_debug.t
    91_miscargs.t
);
#push @tests_confirmed, 't/miscargs/901.t';

my %Makefile_Args = (
    NAME         => 'ExtUtils::ModuleMaker',
    VERSION_FROM => 'lib/ExtUtils/ModuleMaker.pm',
    AUTHOR       => 'James E Keenan (jkeenan@cpan.org)',
    ABSTRACT     => 'Better than h2xs for creating modules',
    EXE_FILES    => [ 'scripts/modulemaker' ],
    PREREQ_PM    => {
        'Data::Dumper'      => 0, # in the Perl core
        'Getopt::Std'       => 0, # in the Perl core
        'File::Basename'    => 0, # in the Perl core
        'File::Path'        => 0, # in the Perl core
        ($^O =~ /Win32/ ? ('Win32' => 0) : ()),
        'File::Save::Home'  => 0.03,
        'File::HomeDir'     => 0.86,
    },
    ( $mm_ver < 6.63_03 ? 'BUILD_REQUIRES' : 'TEST_REQUIRES' ) => {
        'IO::Capture'   => 0,
        'Test::More'    => 0.44,
        'File::Copy'    => 0,
        'File::Copy::Recursive::Reduced' => 0.006,
        'File::Path'    => 2.15,
        'Module::Build' => 0,
                    },
    LICENSE      => "perl",
    #test        => { TESTS => join q{ }, map {glob} qw( t/*.t t/*/*.t ) },
    test        => { TESTS => join q{ }, @tests_confirmed },
    ($mm_ver < 6.46 ? () : (META_MERGE => {
        'meta-spec' => { version => 2 },
        dynamic_config => 1,
        resources => {
            homepage => 'http://thenceforward.net/perl/modules/ExtUtils-ModuleMaker/',
            repository => {
                url => 'https://github.com/jkeenan/extutils-modulemaker.git',
                web => 'https://github.com/jkeenan/extutils-modulemaker',
                type => 'git',
            },
            bugtracker => {
                web => 'https://rt.cpan.org/Public/Dist/Display.html?Name=ExtUtils-ModuleMaker',
            },
        },
    })),
);

WriteMakefile(%Makefile_Args);


use ExtUtils::MakeMaker;
require 5.006001;

my $mm_ver = ExtUtils::MakeMaker->VERSION;

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


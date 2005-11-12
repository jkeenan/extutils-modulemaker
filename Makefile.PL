use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'ExtUtils::ModuleMaker',
    VERSION_FROM => 'lib/ExtUtils/ModuleMaker.pm',
    AUTHOR       => 'James E Keenan (jkeenan@cpan.org)',
    ABSTRACT     => 'Better than h2xs for creating modules',
    EXE_FILES    => [ 'scripts/modulemaker' ],
    PREREQ_PM    => {
        Test::More      => 0.44,
        Getopt::Std     => 0, # in the Perl core
        File::Basename  => 0, # in the Perl core
        File::Path      => 0, # in the Perl core
        ($^O =~ /Win32/ ? (Win32 => 0) : ()),
    },
    test        => { TESTS => join q{ }, map {glob} qw( t/*.t t/*/*.t ) },
);


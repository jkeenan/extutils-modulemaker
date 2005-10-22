use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'ExtUtils::ModuleMaker',
    VERSION_FROM => 'lib/ExtUtils/ModuleMaker.pm',
    AUTHOR       => 'James E Keenan (jkeenan@cpan.org)',
    ABSTRACT     => 'A simple replacement for h2xs -XA',
    EXE_FILES    => [
                        'scripts/modulemaker',
                    ],
    PREREQ_PM    => {
                        Test::More      => 0.44,
                        Getopt::Std     => 0, # in the Perl core
                        File::Basename  => 0, # in the Perl core
                        File::Path      => 0, # in the Perl core
                    },
    test        => { TESTS => join q{ }, map {glob} qw( t/*.t t/*/*.t ) },
);


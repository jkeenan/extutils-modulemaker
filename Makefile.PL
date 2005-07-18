use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'ExtUtils::ModuleMaker',
    VERSION_FROM => 'lib/ExtUtils/ModuleMaker.pm', # finds $VERSION
#    AUTHOR       => 'R. Geoffrey Avery (modulemaker@PlatypiVentures.com)',
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
                        File::Temp      => 0, # in the Perl core since 5.6
                    },
);


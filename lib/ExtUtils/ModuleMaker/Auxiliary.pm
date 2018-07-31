package ExtUtils::ModuleMaker::Auxiliary;
use strict;
# Contains test subroutines for distribution with ExtUtils::ModuleMaker
use warnings;
our ( $VERSION, @ISA, @EXPORT_OK );
$VERSION = "0.63";
require Exporter;
@ISA         = qw(Exporter);
@EXPORT_OK   = qw(
    read_file_string
    read_file_array
    five_file_tests
    check_MakefilePL
    failsafe
    licensetest
    prepare_mockdirs
    prepare_mock_homedir
    basic_file_and_directory_tests
    license_text_test
    compact_build_tests
    check_pm_file
    pod_present
    constructor_present
);
use Carp;
use Cwd;
use File::Path;
use File::Spec;
use File::Temp qw| tempdir |;
no warnings 'once';
*ok = *Test::More::ok;
*is = *Test::More::is;
*isnt = *Test::More::isnt;
*like = *Test::More::like;
use warnings;
use lib ( qw| ./t/testlib | );
use ExtUtils::ModuleMaker::MockHomeDir;

=head1 NAME

ExtUtils::ModuleMaker::Auxiliary - Subroutines for testing ExtUtils::ModuleMaker

=head1 DESCRIPTION

This package contains subroutines used in one or more F<t/*.t> files in
ExtUtils::ModuleMaker's test suite.  They may prove useful in writing test
suites for distributions which subclass ExtUtils::ModuleMaker.

=head1 SUBROUTINES

=head2 C<read_file_string()>

    Function:   Read the contents of a file into a string.
    Argument:   String holding name of a file created by complete_build().
    Returns:    String holding text of the file read.
    Used:       To see whether text of files such as README, Makefile.PL,
                etc. was created correctly by returning a string against which
                a pattern can be matched.

=cut

sub read_file_string {
    my $file = shift;
    open my $fh, $file or die "Unable to open filehandle: $!";
    my $filetext = do { local $/; <$fh> };
    close $fh or die "Unable to close filehandle: $!";
    return $filetext;
}

=head2 C<read_file_array()>

    Function:   Read a file line-by-line  into an array.
    Argument:   String holding name of a file created by complete_build().
    Returns:    Array holding the lines of the file read.
    Used:       To see whether text of files such as README, Makefile.PL,
                etc. was created correctly by returning an array against whose
                elements patterns can be matched.

=cut

sub read_file_array {
    my $file = shift;
    open my $fh, $file or die "Unable to open filehandle: $!";
    my @filetext = <$fh>;
    close $fh or die "Unable to close filehandle: $!";
    return @filetext;
}

=head2 C<five_file_tests()>

    Function:   Verify that content of MANIFEST and lib/*.pm were created
                correctly.
    Argument:   Two arguments:
                1.  A number predicting the number of entries in the MANIFEST.
                2.  A reference to an array holding the components of the module's name, e.g.:
                    [ qw( Alpha Beta Gamma ) ].
    Returns:    n/a.
    Used:       To see whether MANIFEST and lib/*.pm have correct text.
                Runs 6 Test::More tests:
                1.  Number of entries in MANIFEST.
                2.  Change to directory under lib.
                3.  Applies read_file_string to the stem.pm file.
                4.  Determine whether stem.pm's POD contains module name and
                    abstract.
                5.  Determine whether POD contains a HISTORY head.
                6.  Determine whether POD contains correct author information.

=cut

sub five_file_tests {
    my ($manifest_entries, $components) = @_;
    my $module_name = join('::' => @{$components});
    my $dist_name = join('-' => @{$components});
    my $path_str = File::Spec->catdir('lib', @{$components});

    my @filetext = read_file_array(File::Spec->catfile($dist_name, 'MANIFEST'));
    is(scalar(@filetext), $manifest_entries,
        'Correct number of entries in MANIFEST');

    my $module = File::Spec->catfile(
        $dist_name,
        'lib',
        @{$components}[0 .. ($#$components - 1)],
        "$components->[-1].pm",
    );
    my $str;
    ok($str = read_file_string($module),
        "Able to read $module");
    ok($str =~ m|$module_name\s-\sTest\sof\sthe\scapacities\sof\sEU::MM|,
        'POD contains module name and abstract');
    ok($str =~ m|=head1\sHISTORY|,
        'POD contains history head');
    ok($str =~ m|
            Phineas\sT\.\sBluster\n
            \s+CPAN\sID:\s+PTBLUSTER\n
            \s+Peanut\sGallery\n
            \s+phineas\@anonymous\.com\n
            \s+http:\/\/www\.anonymous\.com\/~phineas
            |xs,
        'POD contains correct author info');
}

=head2 C<check_MakefilePL()>

    Function:   Verify that content of Makefile.PL was created correctly.
    Argument:   Two arguments:
                1.  A string holding the directory in which the Makefile.PL
                    should have been created.
                2.  A reference to an array holding strings each of which is a
                    prediction as to content of particular lines in Makefile.PL.
    Returns:    n/a.
    Used:       To see whether Makefile.PL created by complete_build() has
                correct entries.  Runs 1 Test::More test which checks NAME,
                VERSION_FROM, AUTHOR and ABSTRACT.

=cut

sub check_MakefilePL {
    my ($topdir, $predictref) = @_;
    my @pred = @$predictref;

    my $mkfl = File::Spec->catfile( $topdir, q{Makefile.PL} );
    my $bigstr = read_file_string($mkfl);
    like($bigstr, qr/
            NAME.+$pred[0].+
            VERSION_FROM.+$pred[1].+
            AUTHOR.+$pred[2].+
            \($pred[3]\).+
            ABSTRACT.+$pred[4]
        /sx, "Makefile.PL has predicted values");
}

sub failsafe {
    my ($caller, $argslistref, $pattern, $message) = @_;
    my ($tdir, $obj);
    $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');
    local $@ = undef;
    eval { $obj  = $caller->new (@$argslistref); };
    like($@, qr/$pattern/, $message);
}

sub licensetest {
    my ($caller, $license, $pattern) = @_;
    my ($tdir, $mod);
    $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, "changed to temp directory for testing $license");

    ok($mod = $caller->new(
        NAME      => "Alpha::$license",
        LICENSE   => $license,
        COMPACT   => 1,
    ), "object for module Alpha::$license created");
    ok( $mod->complete_build(), 'call complete_build()' );
    ok(chdir "Alpha-$license", "changed to Alpha-$license directory");
    my $licensetext = read_file_string('LICENSE');
    like($licensetext, $pattern, "$license license has predicted content");
    ok(chdir $tdir, "CLEANUP tempdir");
}

sub prepare_mockdirs {
    my $home_dir = prepare_mock_homedir();
    my $personal_defaults_dir = ExtUtils::ModuleMaker::MockHomeDir::personal_defaults_dir();
    croak "Unable to locate '$personal_defaults_dir'" unless (-d $personal_defaults_dir);
    ok(-d $personal_defaults_dir, "Directory $personal_defaults_dir created to mock home directory");
    return ($home_dir, $personal_defaults_dir);
}

sub prepare_mock_homedir {
    my $home_dir = ExtUtils::ModuleMaker::MockHomeDir::home_dir();
    croak "Unable to locate '$home_dir'" unless (-d $home_dir);
    ok(-d $home_dir, "Directory $home_dir created to mock home directory");
    return $home_dir;
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
}

sub license_text_test {
    my ($dist_name, $regex) = @_;
    my $filetext;
    {
        open my $FILE, '<', File::Spec->catfile($dist_name, 'LICENSE')
            or croak "Unable to open LICENSE for reading";
        $filetext = do {local $/; <$FILE>};
        close $FILE or croak "Unable to close LICENSE after reading";
    }
    ok($filetext =~ m/$regex/, "correct LICENSE generated");
}

sub compact_build_tests {
    # Assumes COMPACT => 1
    my ($components) = @_;
    my $dist_name = join('-' => @{$components});
    ok( -d $dist_name, "compact top-level directory exists" );
    basic_file_and_directory_tests($dist_name);
    license_text_test($dist_name, qr/Terms of Perl itself/);

    my ($filetext);
    ok($filetext = read_file_string(File::Spec->catfile($dist_name, 'Makefile.PL')),
        'Able to read Makefile.PL');

    my $module_file = File::Spec->catfile(
        $dist_name,
        'lib',
        @{$components}[0 .. ($#$components - 1)],
        "$components->[-1].pm",
    );
    my $test_file = File::Spec->catfile(
        $dist_name,
        't',
        '001_load.t',
    );
    for my $ff ($module_file, $test_file) {
        ok( -f $ff, "$ff exists");
    }
    return ($module_file, $test_file);
}

sub check_pm_file {
    my ($pmfile, $predictref) = @_;
    my %pred = %$predictref;
    my @pmlines;
    @pmlines = read_file_array($pmfile);
    ok( scalar(@pmlines), ".pm file has content");
    if (defined $pred{'pod_present'}) {
         pod_present(\@pmlines, \%pred);
    }
    if (defined $pred{'constructor_present'}) {
         constructor_present(\@pmlines, \%pred);
    }
}

sub pod_present {
    my $linesref = shift;
    my $predictref = shift;
    my $podcount  = grep {/^=(head|cut)/} @{$linesref};
    if (${$predictref}{'pod_present'} == 0) {
        is( $podcount, 0, "no POD correctly detected in module");
    } else {
        isnt( $podcount, 0, "POD detected in module");
    }
}

sub constructor_present {
    my $linesref = shift;
    my $predictref = shift;
    my $constructorcount  = grep {/^=sub new/} @{$linesref};
    if (${$predictref}{'constructor_present'} == 0) {
        is( $constructorcount, 0, "constructor correctly absent from module");
    } else {
        isnt( $constructorcount, 0, "constructor correctly present in module");
    }
}

=head1 SEE ALSO

F<ExtUtils::ModuleMaker>.

=cut

1;


# t/82_modulemaker.t
# tests of the modulemaker utility
use strict;
use warnings;
use Carp;
use Cwd;
use File::Spec;
use File::Temp qw(tempdir);
use Test::More;
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
    prepare_mockdirs
    basic_file_and_directory_tests
    license_text_test
    check_MakefilePL
    compact_build_tests
    check_pm_file
    read_file_string
) );
use Capture::Tiny qw( :all );

my $cwd = cwd();
my %reg_def = (
    AUTHOR      => "A\.\\sU\.\\sThor",
    EMAIL       => "a\.u\.thor\@a\.galaxy\.far\.far\.away",
    ABSTRACT    => "Module\\sabstract\\s\\(<=\\s44\\scharacters\\)\\sgoes\\shere",
);

{
    note("Set 1:  test against Testing::Defaults");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my (@components, $module_name, $dist_name, $path_str);
    my ($mf);
    @components = ( qw| EU MM Testing Defaults | );
    $module_name = join('::' => @components);
    $dist_name = join('-' => @components);
    $path_str = File::Spec->catdir(@components);
    $mf = join('/' => (
        'lib', @components[0 .. ($#components - 1)], "$components[-1].pm"));

    my ($abstract, $author, $cpanid, $organization, $website, $email);
    $abstract = "Module abstract (<= 44 characters) goes here";
    $author = "Hilton Stallone";
    $cpanid = 'RAMBO';
    $organization = 'Parliamentary Pictures';
    $website = 'http://parliamentarypictures.com';
    $email = 'hiltons\@parliamentarypictures.com';

    my @system_args = (
        $^X, qq{-I$cwd/blib/lib}, qq{$cwd/blib/script/modulemaker},
        '-I',
        '-n' . $module_name,
        '-a' . qq{$abstract},
        '-u' . $author,
        '-p' . $cpanid,
        '-o' . $organization,
        '-w' . $website,
        '-e' . $email,
    );
    my ($stdout, $stderr, @results);
    ($stdout, $stderr, @results) = capture { system(@system_args); };
    ok(! $results[0], "system call to modulemaker exited successfully");

    basic_file_and_directory_tests($path_str);
    license_text_test($path_str, qr/Terms of Perl itself/);

    my @pred = (
        $module_name,
        quotemeta($mf),
        quotemeta($author),
        quotemeta($email),
        quotemeta($abstract),
    );

    check_MakefilePL($path_str, \@pred);

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set 2:  compact build; specify abstract");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my (@components, $module_name, $dist_name, $path_str);
    my ($mf);
    @components = ( qw| XYZ ABC | );
    $module_name = join('::' => @components);
    $dist_name = join('-' => @components);
    $path_str = File::Spec->catdir(@components);
    $mf = join('/' => (
        'lib', @components[0 .. ($#components - 1)], "$components[-1].pm"));

    my ($abstract, $author, $cpanid, $organization, $website, $email);
    $abstract = "This is very abstract.";
    my @system_args = (
        $^X, qq{-I$cwd/blib/lib}, qq{$cwd/blib/script/modulemaker},
        '-I',
        '-c',
        '-n' . $module_name,
        '-a' . qq{$abstract},
    );
    my ($stdout, $stderr, @results);
    ($stdout, $stderr, @results) = capture { system(@system_args); };
    ok(! $results[0], "system call to modulemaker exited successfully");

    my ($module_file, $test_file) = compact_build_tests(\@components);

    my @pred = (
        $module_name,
        quotemeta($mf),
        $reg_def{AUTHOR},
        $reg_def{EMAIL},
        quotemeta($abstract),
    );

    check_MakefilePL($dist_name, \@pred);

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set 3:  compact build; specify abstract and author");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my (@components, $module_name, $dist_name, $path_str);
    my ($mf);
    @components = ( qw| XYZ ABC | );
    $module_name = join('::' => @components);
    $dist_name = join('-' => @components);
    $path_str = File::Spec->catdir(@components);
    $mf = join('/' => (
        'lib', @components[0 .. ($#components - 1)], "$components[-1].pm"));

    my ($abstract, $author, $cpanid, $organization, $website, $email);
    $abstract = "This is very abstract.";
    $author = "John Q Public";
    my @system_args = (
        $^X, qq{-I$cwd/blib/lib}, qq{$cwd/blib/script/modulemaker},
        '-I',
        '-c',
        '-n' . $module_name,
        '-a' . qq{$abstract},
        '-u' . $author,
    );
    my ($stdout, $stderr, @results);
    ($stdout, $stderr, @results) = capture { system(@system_args); };
    ok(! $results[0], "system call to modulemaker exited successfully");

    my ($module_file, $test_file) = compact_build_tests(\@components);

    my @pred = (
        $module_name,
        quotemeta($mf),
        quotemeta($author),
        $reg_def{EMAIL},
        quotemeta($abstract),
    );

    check_MakefilePL($dist_name, \@pred);

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set 4:  compact build; specify abstract, author and email");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my (@components, $module_name, $dist_name, $path_str);
    my ($mf);
    @components = ( qw| XYZ ABC | );
    $module_name = join('::' => @components);
    $dist_name = join('-' => @components);
    $path_str = File::Spec->catdir(@components);
    $mf = join('/' => (
        'lib', @components[0 .. ($#components - 1)], "$components[-1].pm"));

    my ($abstract, $author, $cpanid, $organization, $website, $email);
    $abstract = "This is very abstract.";
    $author = "John Q Public";
    $email = 'jqpublic@calamity.jane.net';
    my @system_args = (
        $^X, qq{-I$cwd/blib/lib}, qq{$cwd/blib/script/modulemaker},
        '-I',
        '-c',
        '-n' . $module_name,
        '-a' . qq{$abstract},
        '-u' . $author,
        '-e' . $email,
    );
    my ($stdout, $stderr, @results);
    ($stdout, $stderr, @results) = capture { system(@system_args); };
    ok(! $results[0], "system call to modulemaker exited successfully");

    my ($module_file, $test_file) = compact_build_tests(\@components);

    my @pred = (
        $module_name,
        quotemeta($mf),
        quotemeta($author),
        quotemeta($email),
        quotemeta($abstract),
    );

    check_MakefilePL($dist_name, \@pred);

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set 5:  compact build; omit POD from .pm file");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my (@components, $module_name, $dist_name, $path_str);
    my ($mf);
    @components = ( qw| XYZ ABC | );
    $module_name = join('::' => @components);
    $dist_name = join('-' => @components);
    $path_str = File::Spec->catdir(@components);
    $mf = join('/' => (
        'lib', @components[0 .. ($#components - 1)], "$components[-1].pm"));

    my ($abstract, $author, $cpanid, $organization, $website, $email);
    my @system_args = (
        $^X, qq{-I$cwd/blib/lib}, qq{$cwd/blib/script/modulemaker},
        '-I',
        '-c',
        '-P',
        '-n' . $module_name,
    );
    my ($stdout, $stderr, @results);
    ($stdout, $stderr, @results) = capture { system(@system_args); };
    ok(! $results[0], "system call to modulemaker exited successfully");

    my ($module_file, $test_file) = compact_build_tests(\@components);

    my %pred = (
        'pod_present'       => 0,
    );
    check_pm_file($module_file, \%pred);

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set 6:  compact build; omit constructor from .pm file");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my (@components, $module_name, $dist_name, $path_str);
    my ($mf);
    @components = ( qw| XYZ ABC | );
    $module_name = join('::' => @components);
    $dist_name = join('-' => @components);
    $path_str = File::Spec->catdir(@components);
    $mf = join('/' => (
        'lib', @components[0 .. ($#components - 1)], "$components[-1].pm"));

    my ($abstract, $author, $cpanid, $organization, $website, $email);
    my @system_args = (
        $^X, qq{-I$cwd/blib/lib}, qq{$cwd/blib/script/modulemaker},
        '-I',
        '-c',
        '-q',
        '-n' . $module_name,
    );
    my ($stdout, $stderr, @results);
    ($stdout, $stderr, @results) = capture { system(@system_args); };
    ok(! $results[0], "system call to modulemaker exited successfully");

    my ($module_file, $test_file) = compact_build_tests(\@components);

    my %pred = (
        'constructor_present'       => 0,
    );
    check_pm_file($module_file, \%pred);

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set 7:  compact build; set VERSION to number other than 0.01");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my (@components, $module_name, $dist_name, $path_str);
    my ($mf);
    @components = ( qw| XYZ ABC | );
    $module_name = join('::' => @components);
    $dist_name = join('-' => @components);
    $path_str = File::Spec->catdir(@components);
    $mf = join('/' => (
        'lib', @components[0 .. ($#components - 1)], "$components[-1].pm"));

    my ($abstract, $author, $cpanid, $organization, $website, $email);
    my $version = '0.3';
    my @system_args = (
        $^X, qq{-I$cwd/blib/lib}, qq{$cwd/blib/script/modulemaker},
        '-I',
        '-c',
        '-n' . $module_name,
        '-v' . $version,
    );
    my ($stdout, $stderr, @results);
    ($stdout, $stderr, @results) = capture { system(@system_args); };
    ok(! $results[0], "system call to modulemaker exited successfully");

    my ($module_file, $test_file) = compact_build_tests(\@components);

    my $filetext;
    ok($filetext = read_file_string($module_file), "Able to read $module_file");
    like($filetext, qr/\$VERSION\s+=\s+'\Q$version\E'/,
        "VERSION number is correct and properly quoted");

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set 8:  test help switch: '-h'");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my @system_args = (
        $^X, qq{-I$cwd/blib/lib}, qq{$cwd/blib/script/modulemaker},
        '-h',
    );
    my ($stdout, $stderr, @results);
    ($stdout, $stderr, @results) = capture { system(@system_args); };
    ok(! $results[0], "system call to modulemaker exited successfully");

    like($stdout, qr/^modulemaker \[-CIPVbcgh\]/s,
        "Got expected start of Usage message");
    like($stdout, qr/Currently Supported Features/s,
        "Got expected middle of Usage message");
    like($stdout, qr/modulemaker\s+ExtUtils::ModuleMaker\sversion:\s+\d\.\d{2}$/s,
        "Got expected end of Usage message");

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set 9:  compact build; -b flag sets Module::Build");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my (@components, $module_name, $dist_name, $path_str);
    my ($mf);
    @components = ( qw| XYZ ABC | );
    $module_name = join('::' => @components);
    $dist_name = join('-' => @components);
    $path_str = File::Spec->catdir(@components);
    $mf = join('/' => (
        'lib', @components[0 .. ($#components - 1)], "$components[-1].pm"));

    my ($abstract, $author, $cpanid, $organization, $website, $email);
    my @system_args = (
        $^X, qq{-I$cwd/blib/lib}, qq{$cwd/blib/script/modulemaker},
        '-I',
        '-c',
        '-n' . $module_name,
        '-b',
    );
    my ($stdout, $stderr, @results);
    ($stdout, $stderr, @results) = capture { system(@system_args); };
    ok(! $results[0], "system call to modulemaker exited successfully");

    for my $f ( qw| Changes MANIFEST Build.PL LICENSE README | ) {
        my $ff = File::Spec->catfile($dist_name, $f);
        ok (-e $ff, "$ff exists");
    }
    ok(! -e File::Spec->catfile($dist_name, 'Makefile.PL'),
        "Makefile.PL does not exist");
    for my $d ( qw| lib t | ) {
        my $dd = File::Spec->catdir($dist_name, $d);
        ok(-d $dd, "Directory '$dd' exists");
    }

    ok(chdir $cwd, "Able to change back to starting directory");
}

{
    note("Set 10:  compact build; various other previously untested options");

    my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
    local $ENV{HOME} = $home_dir;

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my (@components, $module_name, $dist_name, $path_str);
    my ($mf);
    @components = ( qw| XYZ ABC | );
    $module_name = join('::' => @components);
    $dist_name = join('-' => @components);
    $path_str = File::Spec->catdir(@components);
    $mf = join('/' => (
        'lib', @components[0 .. ($#components - 1)], "$components[-1].pm"));

    my ($abstract, $author, $cpanid, $organization, $website, $email);
    $organization = 'World Wide Web, Inc.';
    $website = 'http://example.com';
    my $license = 'apache_1_1';
    my @system_args = (
        $^X, qq{-I$cwd/blib/lib}, qq{$cwd/blib/script/modulemaker},
        '-I',
        '-c',
        '-C',  # Changes in POD
        '-n' . $module_name,
        '-l' . $license,
        '-o' . $organization,
        '-w' . $website,
    );
    my ($stdout, $stderr, @results);
    ($stdout, $stderr, @results) = capture { system(@system_args); };
    ok(! $results[0], "system call to modulemaker exited successfully");

    for my $f ( qw| MANIFEST Makefile.PL LICENSE README | ) {
        my $ff = File::Spec->catfile($dist_name, $f);
        ok (-e $ff, "$ff exists");
    }
    for my $f ( qw| Build.PL Changes | ) {
        my $ff = File::Spec->catfile($dist_name, $f);
        ok (! -e $ff, "$ff does not exist");
    }
    for my $d ( qw| lib t | ) {
        my $dd = File::Spec->catdir($dist_name, $d);
        ok(-d $dd, "Directory '$dd' exists");
    }
    license_text_test($dist_name, qr/Apache Software License.*Version 1\.1/s);

    my $filetext = read_file_string(File::Spec->catfile($dist_name, $mf));
    ok($filetext, "Able to read $mf");
    like($filetext, qr/=head1 HISTORY/s, "HISTORY section placed in POD");
    like($filetext, qr/original version; created by ExtUtils::ModuleMaker/s,
        "Got expected text in HISTORY");
    like($filetext, qr/=head1 AUTHOR/s, "AUTHOR section placed in POD");
    like($filetext, qr/\Q$organization\E/s, "Got expected ORGANIZATION");
    like($filetext, qr/\Q$website\E/s, "Got expected WEBSITE");

    ok(chdir $cwd, "Able to change back to starting directory");
}


done_testing();

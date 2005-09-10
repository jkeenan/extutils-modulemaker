package Auxiliary;
# Contains test subroutines for distribution with ExtUtils::ModuleMaker
# As of:  September 9, 2005
use strict;
use warnings;
use vars qw| @ISA @EXPORT_OK |; 
require Exporter;
@ISA         = qw(Exporter);
@EXPORT_OK   = qw(
    read_file_string
    read_file_array
    six_file_tests
    check_MakefilePL 
    check_pm_file
    make_compact
    failsafe
    licensetest
    _process_personal_defaults_file 
    _reprocess_personal_defaults_file 
    _tests_pm_hidden
    _get_els
    _subclass_preparatory_tests
    _subclass_cleanup_tests
); 
use Carp;
use Cwd;
use File::Copy;
use File::Path;
use File::Temp qw| tempdir |;
*ok = *Test::More::ok;
*is = *Test::More::is;
*like = *Test::More::like;
*copy = *File::Copy::copy;
*move = *File::Copy::move;
use ExtUtils::ModuleMaker::Utility qw(
    _preexists_mmkr_directory
    _make_mmkr_directory
    _restore_mmkr_dir_status
);
#    _identify_pm_files_under_mmkr_dir
#    _hide_pm_files_under_mmkr_dir
#    _reveal_pm_files_under_mmkr_dir

sub read_file_string {
    my $file = shift;
    open my $fh, $file or die "Unable to open filehandle: $!";
    my $filetext = do { local $/; <$fh> };
    close $fh or die "Unable to close filehandle: $!";
    return $filetext;
}

sub read_file_array {
    my $file = shift;
    open my $fh, $file or die "Unable to open filehandle: $!";
    my @filetext = <$fh>;
    close $fh or die "Unable to close filehandle: $!";
    return @filetext;
}

sub six_file_tests {
    my ($manifest_entries, $testmod) = @_;
    my @filetext = read_file_array('MANIFEST');
    is(scalar(@filetext), $manifest_entries,
        'Correct number of entries in MANIFEST');
    
    my $str;
    ok(chdir 'lib/Alpha', 'Directory is now lib/Alpha');
    ok($str = read_file_string("$testmod.pm"),
        "Able to read $testmod.pm");
    ok($str =~ m|Alpha::$testmod\s-\sTest\sof\sthe\scapacities\sof\sEU::MM|,
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

sub check_MakefilePL {
    my ($topdir, $predictref) = @_;
    my @pred = @$predictref;

    my $mkfl = "$topdir/Makefile.PL";
    local *MAK;
    open MAK, $mkfl or die "Unable to open Makefile.PL: $!";
    my $bigstr;
    {    local $/; $bigstr = <MAK>; }
    close MAK;
    like($bigstr, qr/
            NAME.+($pred[0]).+
            VERSION_FROM.+($pred[1]).+
            AUTHOR.+($pred[2]).+
            ($pred[3]).+
            ABSTRACT.+($pred[4]).+
        /sx, "Makefile.PL has predicted values");
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

sub make_compact {
    my $module_name = shift;
    my ($topdir, $path, $pmfile);
    $topdir = $path = $module_name;
    $topdir =~ s{::}{-}g;
    $path   =~ s{::}{/}g;
    $pmfile = "$topdir/lib/${path}.pm";
    return ($topdir, $pmfile);
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

sub failsafe {
    my ($argslistref, $pattern, $message) = @_;
    my $odir = cwd();
    my ($tdir, $mod);
    $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');
    my $mmkr_dir_ref = _preexists_mmkr_directory();
    my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
    ok( $mmkr_dir, "personal defaults directory now present on system");
    my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
    my $pers_def_ref = 
        _process_personal_defaults_file( $mmkr_dir, $pers_file );
    local $@ = undef;
    eval { $mod  = ExtUtils::ModuleMaker->new (@$argslistref); };
    like($@, qr/$pattern/, $message);
    _reprocess_personal_defaults_file($pers_def_ref);
    ok(chdir $odir, 'changed back to original directory after testing');
    ok( _restore_mmkr_dir_status($mmkr_dir_ref),
        "original presence/absence of .modulemaker directory restored");
}

sub licensetest {
    my ($license, $pattern) = @_;
    my $odir = cwd();
    my ($tdir, $mod);
    $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, "changed to temp directory for testing $license");
    my $mmkr_dir_ref = _preexists_mmkr_directory();
    my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
    ok( $mmkr_dir, "personal defaults directory now present on system");

    my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
    my $pers_def_ref = 
        _process_personal_defaults_file( $mmkr_dir, $pers_file );
    ok($mod = ExtUtils::ModuleMaker->new(
        NAME      => "Alpha::$license",
        LICENSE   => $license,
        COMPACT   => 1,
    ), "object for module Alpha::$license created");
    ok( $mod->complete_build(), 'call complete_build()' );
    ok(chdir "Alpha-$license", "changed to Alpha-$license directory");
    my $licensetext = read_file_string('LICENSE');
    like($licensetext, $pattern, "$license license has predicted content");
    _reprocess_personal_defaults_file($pers_def_ref);
    ok(chdir $odir, 'changed back to original directory after testing');
    ok( _restore_mmkr_dir_status($mmkr_dir_ref),
        "original presence/absence of .modulemaker directory restored");
}

sub _process_personal_defaults_file {
    my ($mmkr_dir, $pers_file) = @_;
    my $pers_file_hidden = "$pers_file" . '.hidden';
    my %pers;
    $pers{full} = "$mmkr_dir/$pers_file";
    $pers{hidden} = "$mmkr_dir/$pers_file_hidden";
    if (-f $pers{full}) {
        $pers{atime}   = (stat($pers{full}))[8];
        $pers{modtime} = (stat($pers{full}))[9];
        rename $pers{full},
               $pers{hidden}
            or croak "Unable to rename $pers{full}: $!";
        ok(! -f $pers{full}, 
            "personal defaults file temporarily suppressed");
        ok(-f $pers{hidden}, 
            "personal defaults file now hidden");
    } else {
        ok(! -f $pers{full}, 
            "personal defaults file not found");
        ok(1, "personal defaults file not found");
    }
    return { %pers };
}

sub _reprocess_personal_defaults_file {
    my $pers_def_ref = shift;;
    if(-f $pers_def_ref->{hidden} ) {
        rename $pers_def_ref->{hidden},
               $pers_def_ref->{full},
            or croak "Unable to rename $pers_def_ref->{hidden}: $!";
        ok(-f $pers_def_ref->{full}, 
            "personal defaults file re-established");
        ok(! -f $pers_def_ref->{hidden}, 
            "hidden personal defaults now gone");
        ok( (utime $pers_def_ref->{atime}, 
                   $pers_def_ref->{modtime}, 
                  ($pers_def_ref->{full})
            ), "atime and modtime of personal defaults file restored");
    } else {
        ok(1, "test not relevant");
        ok(1, "test not relevant");
        ok(1, "test not relevant");
    }
}

sub _get_els {
    my $persref = shift;
    my %pers = %$persref;
    my %pm = %{$pers{pm}};
    my %hidden = %{$pers{hidden}};
    return ( pm => scalar(keys %pm), hidden => scalar(keys %hidden) );
}

sub _tests_pm_hidden {
    my $persref = shift;
    my $predref = shift;
    my %el = _get_els($persref);
    is($el{pm}, $predref->{pm}, "correct number of .pm files");
    is($el{hidden}, $predref->{hidden}, "correct number of .pm.hidden files");
}

sub _subclass_preparatory_tests {
    my $odir = shift;
    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $mmkr_dir_ref = _preexists_mmkr_directory();
    my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
    ok($mmkr_dir, "home/.modulemaker directory now present on system");
    my $eumm = "ExtUtils/ModuleMaker";
    my $eumm_dir = "$mmkr_dir/$eumm";
    unless (-d $eumm_dir) {
            mkpath($eumm_dir) or croak "Unable to make path: $!";
    }
    ok(-d $eumm_dir, "eumm directory now exists");

    my $persref;

    $persref = _identify_pm_files_under_mmkr_dir($eumm_dir);
    my %els1 = _get_els($persref);

    _hide_pm_files_under_mmkr_dir($persref);

    $persref = _identify_pm_files_under_mmkr_dir($eumm_dir);
    my %els2 = _get_els($persref);

    if (! $els1{pm}) {
        is($els1{pm}, $els2{pm}, 
            "no .pm files originally, so no .pm files now");
        is($els1{pm}, $els2{hidden}, 
            "no .pm files originally, so no .pm.hidden files now");
    } elsif ($els1{pm}) {
        is($els2{pm}, 0,
            "original .pm files are now hidden");
        is($els1{pm}, $els2{hidden},
            ".pm.hidden files exist");
    }

    my $sourcedir = "$odir/t/testlib/$eumm";
    ok( -d $sourcedir, "source directory exists");
    ok( -d $eumm_dir, "destination directory exists");
    return {
        mmkr_dir_ref     => $mmkr_dir_ref,
        persref          => $persref,
        initial_els_ref  => \%els1,
        sourcedir        => $sourcedir,
        eumm_dir         => $eumm_dir,
    }
}

sub _subclass_cleanup_tests {
    my $cleanup_ref = shift;
    my $persref         = $cleanup_ref->{persref};
    my $eumm_dir        = $cleanup_ref->{eumm_dir};
    my %els1            = %{ $cleanup_ref->{initial_els_ref} };
    my $odir            = $cleanup_ref->{odir}; 
    my $mmkr_dir_ref    = $cleanup_ref->{mmkr_dir_ref};

    _reveal_pm_files_under_mmkr_dir($persref);

    $persref = _identify_pm_files_under_mmkr_dir($eumm_dir);
    my %els3 = _get_els($persref);

    if (! $els1{pm}) {
        is($els1{pm}, $els3{pm}, 
            "no .pm files originally, so no .pm files now");
        is($els1{pm}, $els3{hidden}, 
            "no .pm files originally, so no .pm.hidden files now");
    } elsif ($els1{pm}) {
        is($els1{pm}, $els3{pm},
            "same number of .pm files as originally");
        is($els3{hidden}, 0,
            "no more .pm.hidden files");
    }

    ok(chdir $odir, 'changed back to original directory after testing');

    ok( _restore_mmkr_dir_status($mmkr_dir_ref),
        "original presence/absence of .modulemaker directory restored");
}

sub _identify_pm_files_under_mmkr_dir {
    my $eumm_dir = shift;
    my (@pm_files, @pm_files_hidden);
    opendir my $dirh, $eumm_dir 
        or croak "Unable to open $eumm_dir for reading: $!";
# warn "exists: $eumm_dir";
    while (my $f = readdir($dirh)) {
        if ($f =~ /\.pm$/) {
            push @pm_files, "$eumm_dir/$f";
        } elsif ($f =~ /\.pm\.hidden$/) {
            push @pm_files_hidden, "$eumm_dir/$f";
        } else {
            next;
        }
    }
    closedir $dirh or croak "Unable to close $eumm_dir after reading: $!";
#warn "pm_files:  @pm_files";
#warn "pm_hidden_files:  @pm_files_hidden";
#    # sanity check:
    # If there are .pm files, there should be no .pm.hidden files
    # and vice versa.
    if ( scalar(@pm_files) and scalar(@pm_files_hidden) )  {
        croak "Both .pm and .pm.hidden files found in $eumm_dir: $!";
    }
    my %pers;
    my %pm;
    foreach my $f (@pm_files) {
        $pm{$f}{atime}   = (stat($f))[8];
        $pm{$f}{modtime} = (stat($f))[9];
    }
    my %hidden;
    foreach my $f (@pm_files_hidden) {
        $hidden{$f}{atime}   = (stat($f))[8];
        $hidden{$f}{modtime} = (stat($f))[9];
    }
    $pers{dir}    = $eumm_dir;;
    $pers{pm}     = \%pm;
    $pers{hidden} = \%hidden;
    return \%pers;
}

sub _hide_pm_files_under_mmkr_dir {
    my $per_dir_ref = shift;
    my %pers = %{$per_dir_ref};
    my %pm = %{$pers{pm}};
    foreach my $f (keys %pm) {
        my $new = "$f.hidden";
        rename $f, $new or croak "Unable to rename $f: $!";
        utime $pm{$f}{atime}, $pm{$f}{modtime}, $new;
    }
}

sub _reveal_pm_files_under_mmkr_dir {
    my $per_dir_ref = shift;
    my %pers = %{$per_dir_ref};
    my %hidden = %{$pers{hidden}};
    foreach my $f (keys %hidden) {
        $f =~ m{(.*)\.hidden$};
        my $new = $1;
        rename $f, $new or croak "Unable to rename $f: $!";
        utime $hidden{$f}{atime}, $hidden{$f}{modtime}, $new;
    }
}

1;


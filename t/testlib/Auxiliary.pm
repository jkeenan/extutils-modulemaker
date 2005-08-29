package Auxiliary;
# Contains test subroutines for distribution with ExtUtils::ModuleMaker
# As of:  August 24, 2005
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
    _starttest
    _endtest
    _get_realhome
    _get_pseudodir
    _get_personal_defaults
    _restore_personal_defaults
    _process_personal_defaults_file 
    _reprocess_personal_defaults_file 
); 
use File::Temp qw| tempdir |;
use Cwd;
use File::Copy;
use Carp;
*ok = *Test::More::ok;
*is = *Test::More::is;
*like = *Test::More::like;
*copy = *File::Copy::copy;
*move = *File::Copy::move;
use ExtUtils::ModuleMaker::Utility qw(
    _get_personal_defaults_directory
    _restore_personal_dir_status
);

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
    $topdir =~ s/::/-/g;
    $path =~ s/::/\//g;
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
    my ($personal_dir, $no_personal_dir_flag) = 
        _get_personal_defaults_directory();
    ok( $personal_dir, "personal defaults directory now present on system");
    my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
    my $pers_def_ref = 
        _process_personal_defaults_file( $personal_dir, $pers_file );
    local $@ = undef;
    eval { $mod  = ExtUtils::ModuleMaker->new (@$argslistref); };
    like($@, qr/$pattern/, $message);
    _reprocess_personal_defaults_file($pers_def_ref);
    ok(chdir $odir, 'changed back to original directory after testing');
    ok( _restore_personal_dir_status($personal_dir, $no_personal_dir_flag),
        "original presence/absence of .modulemaker directory restored");
}

sub licensetest {
    my ($license, $pattern) = @_;
    my $odir = cwd();
    my ($tdir, $mod);
    $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, "changed to temp directory for testing $license");
    my ($personal_dir, $no_personal_dir_flag) = 
        _get_personal_defaults_directory();
    ok( $personal_dir, "personal defaults directory now present on system");

    my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
    my $pers_def_ref = 
        _process_personal_defaults_file( $personal_dir, $pers_file );
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
    ok( _restore_personal_dir_status($personal_dir, $no_personal_dir_flag),
        "original presence/absence of .modulemaker directory restored");
}

sub _starttest {
    my $realhome = _get_realhome();
    local $ENV{HOME} = _get_pseudodir("./t/testlib/pseudohome"); # 2 tests
    my ( $personal_dir, $personal_defaults_file ) = 
        _get_personal_defaults($ENV{HOME});  # 1 test
    return ( $realhome, $personal_dir, $personal_defaults_file );
}

sub _endtest {
    my ($realhome, $personal_dir, $personal_defaults_file) = @_;
    $ENV{HOME} = $realhome;
    ( $personal_dir, $personal_defaults_file ) = 
        _restore_personal_defaults( 
            $personal_dir, $personal_defaults_file 
        ); # 1 test
}

sub _get_realhome {
    my $realhome;
    if ($^O eq 'MSWin32') {
        require Win32;
        Win32->import( qw(CSIDL_LOCAL_APPDATA) );  # 0x001c 
        $realhome =  Win32::GetFolderPath( CSIDL_LOCAL_APPDATA() );
    } else {
        $realhome = $ENV{HOME};
    }
}
sub _get_pseudodir {
    my $pseudodir = shift;
    ok(-d $pseudodir, "_starttest:  pseudohome directory exists");
    like($pseudodir, qr/pseudohome/, "_starttest:  pseudohome identified");
    return $pseudodir;
}

sub _get_personal_defaults {
    my $home = shift;
    my $personal_dir = "$home/.modulemaker"; 
    my $personal_defaults_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
    if (-f "$personal_dir/$personal_defaults_file") {
        move("$personal_dir/$personal_defaults_file", 
             "$personal_dir/$personal_defaults_file.bak"); 
        ok(-f "$personal_dir/$personal_defaults_file.bak",
            "_starttest:  personal defaults stored as .bak"); 
    } else {
        ok(1, "_starttest:  no personal defaults file found");
    }
    return ( $personal_dir, $personal_defaults_file );
}

sub _restore_personal_defaults {
    my ( $personal_dir,  $personal_defaults_file ) = @_;
    if (-f "$personal_dir/$personal_defaults_file.bak") {
        move("$personal_dir/$personal_defaults_file.bak", 
             "$personal_dir/$personal_defaults_file"); 
        ok(-f "$personal_dir/$personal_defaults_file",
            "_endtest:  personal defaults restored"); 
    } else {
        ok(1, "_endtest: no personal defaults file found");
    }
    return ( $personal_dir,  $personal_defaults_file );
}

sub _process_personal_defaults_file {
    my ($personal_dir, $pers_file) = @_;
    my $pers_file_hidden = "$pers_file" . '.hidden';
    my %pers;
    $pers{full} = "$personal_dir/$pers_file";
    $pers{hidden} = "$personal_dir/$pers_file_hidden";
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

1;


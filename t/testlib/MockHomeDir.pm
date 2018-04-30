package MockHomeDir;
# Adapted from CPAN-Reporter's t/lib/MockHomeDir.pm
use 5.006001;
use strict;
use warnings;
use File::Copy;
use File::Spec;
use File::Path 2.15 qw(make_path);
use File::Temp qw/tempdir/;

my $testlib_dir = File::Spec->catdir(qw| . t testlib |);
my @components = qw| ExtUtils ModuleMaker Testing Defaults |;
my $package = join('::' => @components);
my $per_package = join('::' => @components[0..1], 'Personal', $components[3]);
my @pmfile_components = (@components[0..2], "$components[3].pm");
my $testing_defaults_file =
    File::Spec->catfile($testlib_dir, @pmfile_components);
die "Could not locate $testing_defaults_file" unless -f $testing_defaults_file;

unshift @INC, $testlib_dir;
eval "require $package" or die "Unable";

$INC{"File/HomeDir.pm"} = 1; # fake load

my $temp_home = tempdir(
    "ModuleMaker-XXXXXXXX", TMPDIR => 1, CLEANUP => 1
) or die "Couldn't create a temporary config directory: $!\nIs your temp drive full?";

my $home_dir = File::Spec->rel2abs( $temp_home );
my $subdir = '.modulemaker';
my $personal_defaults_dir =
    File::Spec->catdir($home_dir, $subdir, qw| ExtUtils ModuleMaker Personal | );
make_path($personal_defaults_dir, { mode => 0711 });
die "Unable to create $personal_defaults_dir for testing"
    unless -d $personal_defaults_dir;

sub home_dir { $home_dir }
sub personal_defaults_dir { $personal_defaults_dir }

sub personal_defaults_file {
    my $newfile = File::Spec->catfile($personal_defaults_dir, 'Defaults.pm');
    open my $OUT, '>', $newfile or die "Unable to open $newfile for writing";
    print $OUT <<TOP_OF_PACKAGE;
package $per_package;
use strict;
use warnings;

my \$usage = <<ENDOFUSAGE;
TOP_OF_PACKAGE
    print $OUT ExtUtils::ModuleMaker::Testing::Defaults::get_usage_as_string();
    print $OUT <<MIDDLE_OF_PACKAGE;
ENDOFUSAGE

my \%default_values = (
MIDDLE_OF_PACKAGE
    print $OUT ExtUtils::ModuleMaker::Testing::Defaults::get_default_values_as_string();
    print $OUT <<BOTTOM_OF_PACKAGE;
);

sub default_values {
    my \$self = shift;
    return { %default_values };
}

1;
BOTTOM_OF_PACKAGE
    close $OUT or die "Unable to close $newfile after writing";
    return $newfile;
}

package File::HomeDir;
our $VERSION = 999;
sub my_documents { return $home_dir };
sub my_home { return $home_dir };
sub my_data { return $home_dir };

1;


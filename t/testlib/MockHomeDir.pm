package MockHomeDir;
# Adapted from CPAN-Reporter's t/lib/MockHomeDir.pm
use 5.006001;
use strict;
use warnings;
use File::Spec;
use File::Path 2.15 qw(make_path);
use File::Temp qw/tempdir/;

$INC{"File/HomeDir.pm"} = 1; # fake load

my $temp_home = tempdir(
    "Modulemaker-XXXXXXXX", TMPDIR => 1, CLEANUP => 1
) or die "Couldn't create a temporary config directory: $!\nIs your temp drive full?";

my $home_dir = File::Spec->rel2abs( $temp_home );
my $subdir = '.modulemaker';
my $personal_defaults_dir =
    File::Spec->catdir($home_dir, $subdir, qw| lib ExtUtils Modulemaker Personal | );
make_path($personal_defaults_dir, { mode => 0711 });
die "Unable to create $personal_defaults_dir for testing"
    unless -d $personal_defaults_dir;

sub home_dir { $home_dir }
sub personal_defaults_dir { $personal_defaults_dir }

package File::HomeDir;
our $VERSION = 999;
sub my_documents { return $home_dir };
sub my_home { return $home_dir };
sub my_data { return $home_dir };

1;


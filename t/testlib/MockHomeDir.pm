package MockHomeDir;
# Adapted from CPAN-Reporter's t/lib/MockHomeDir.pm
use strict;
BEGIN{ if (not $] < 5.006) { require warnings; warnings->import } }
use File::Spec;
use File::Temp qw/tempdir/;

$INC{"File/HomeDir.pm"} = 1; # fake load

my $temp_home = tempdir(
    "Modulemaker-XXXXXXXX", TMPDIR => 1, CLEANUP => 1
) or die "Couldn't create a temporary config directory: $!\nIs your temp drive full?";

my $home_dir = File::Spec->rel2abs( $temp_home );

sub home_dir { $home_dir }

package File::HomeDir;
our $VERSION = 999;
sub my_documents { return $home_dir };
sub my_home { return $home_dir };
sub my_data { return $home_dir };

1;


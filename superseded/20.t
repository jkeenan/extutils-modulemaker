# t/13_license.t
use strict;
local $^W = 1;
use Test::More 
# tests =>    9;
qw(no_plan);
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'Cwd' );

my $cwd = cwd();
my $tdf = "$cwd/t/testlib/ExtUtils/ModuleMaker/Testing/Defaults.pm";
ok(-f $tdf, "testing defaults file correctly located"); 

my $mod = ExtUtils::ModuleMaker->new(
    TESTING_DEFAULTS_FILE => $tdf,
);

isa_ok($mod, 'ExtUtils::ModuleMaker');

my %pred = (
    A => [ AUTHOR =>       'Hilton Stallone' ],
    C => [ CPANID =>       'RAMBO' ],
    O => [ ORGANIZATION => 'Parliamentary Pictures' ],
    W => [ WEBSITE =>      'http://parliamentarypictures.com' ],
    E => [ EMAIL =>        'hiltons@parliamentarypictures.com' ],
);

for my $x (qw| A C O W E |) {
    is($mod->{$pred{$x}[0]}, $pred{$x}[1],
        "personal default $pred{$x}[1] for $pred{$x}[0] is okay");
}

__END__

use_ok( 'ExtUtils::ModuleMaker::Licenses::Local' );
use_ok( 'Cwd');

=for PseudohomePersonalDefaults:
    In this file (a) pseudohome is being used as realhome, but (b) the
Personal Defaults file there is *not* being renamed as *.bak.  Hence (c)
EU::MM is detecting the presence of a personal defaults file and is overriding
EU::MM::Defaults.pm.  The values in this personal defaults file (Rambo) are
what is being tested below.

=cut

#!/usr/local/bin/perl
BEGIN {
    use Test::More tests => 9;
    if ($^O eq 'MSWin32') {
        use Win32 qw(CSIDL_LOCAL_APPDATA);
        $realhome =  Win32::GetFolderPath(CSIDL_LOCAL_APPDATA);
#    } else {
#        $realhome = $ENV{HOME};
    }
    $realhome = $ENV{HOME};
    local $ENV{HOME} = "./t/testlib/pseudohome";
    ok(-d $ENV{HOME}, "pseudohome directory exists");
    like($ENV{HOME}, qr/pseudohome/, "pseudohome identified");
    use_ok( 'ExtUtils::ModuleMaker' );
}
END {
    $ENV{HOME} = $realhome;
}
use strict;
local $^W = 1;


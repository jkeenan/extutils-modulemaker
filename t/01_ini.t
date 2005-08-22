# t/01_ini.t - check module loading
BEGIN {
    use Test::More 
    tests =>  7;
#    qw(no_plan);
    $realhome = $ENV{HOME};
    local $ENV{HOME} = "./t/testlib/pseudohome";
    ok(-d $ENV{HOME}, "pseudohome directory exists");
    like($ENV{HOME}, qr/pseudohome/, "pseudohome identified");
    use_ok( 'ExtUtils::ModuleMaker' );
    use_ok( 'ExtUtils::ModuleMaker::Licenses::Standard' );
    use_ok( 'ExtUtils::ModuleMaker::Licenses::Local' );
    use_ok( 'File::Path'); # because it is needed by EU::MM
    use_ok( 'Cwd' );
}
END {
    $ENV{HOME} = $realhome;
}
use strict;
local $^W = 1;


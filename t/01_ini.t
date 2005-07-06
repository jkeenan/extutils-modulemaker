# t/01_ini.t - check module loading
use strict;
local $^W = 1;

use Test::More tests => 4;

BEGIN {
    use_ok( 'ExtUtils::ModuleMaker' );
    use_ok( 'ExtUtils::ModuleMaker::Licenses::Standard' );
    use_ok( 'ExtUtils::ModuleMaker::Licenses::Local' );
    use_ok( 'File::Path'); # because it is needed by EU::MM
}


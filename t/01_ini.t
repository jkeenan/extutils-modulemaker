# t/01_ini.t - check module loading
use strict;
local $^W = 1;
use Test::More 
tests =>  6;
# qw(no_plan);
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'Cwd');
use lib ("./t/testlib");
use _Auxiliary qw(
    _starttest
    _endtest
);

my ($realhome, $personal_dir, $personal_defaults_file) = _starttest();

END { _endtest($realhome, $personal_dir, $personal_defaults_file); }


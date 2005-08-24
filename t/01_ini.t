# t/01_ini.t - check module loading
use strict;
local $^W = 1;
use Test::More 
tests =>  2;
# qw(no_plan);
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'Cwd');


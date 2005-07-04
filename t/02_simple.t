# t/02_simple.t; A very simple module to make sure the parts are created
# -*- perl -*-
use strict;
use warnings;

use Test::More tests => 3;

BEGIN { use_ok( 'ExtUtils::ModuleMaker' ); }
BEGIN { use_ok( 'ExtUtils::ModuleMaker::Licenses::Standard' ); }
BEGIN { use_ok( 'ExtUtils::ModuleMaker::Licenses::Local' ); }


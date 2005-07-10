# t/02_bad constructor.t

use Test::More 
# tests => 15;
qw(no_plan);
use strict;
local $^W = 1;

BEGIN { use_ok( 'ExtUtils::ModuleMaker' ); }
BEGIN { use_ok( 'File::Temp', qw| tempdir |); }

my $tdir = tempdir( CLEANUP => 1);
ok(chdir $tdir, 'changed to temp directory for testing');

###########################################################################

my $mod;

eval { $mod  = ExtUtils::ModuleMaker->new ( 'NAME' ); };
ok($@ =~ /^Must be hash or balanced list of key-value pairs:/,
    "Constructor correctly failed due to odd number of arguments");

eval { $mod  = ExtUtils::ModuleMaker->new ( 'NAME' => 'Jim', 'ABSTRACT' ); };
ok($@ =~ /^Must be hash or balanced list of key-value pairs:/,
    "Constructor correctly failed due to odd number of arguments");

eval { $mod  = ExtUtils::ModuleMaker->new (
    'NAME' => 'Jim',
    'FIRST' => 'Avery',
    'SECOND' => 'Keenan',
); };
ok($@ =~ /^Dying due to bad input to constructor/,
    "Constructor correctly failed due to invalid keys");


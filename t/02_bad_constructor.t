# t/02_bad constructor.t

use Test::More 
# qw(no_plan);
tests => 14;
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

eval { $mod  = ExtUtils::ModuleMaker->new (
    'ABSTRACT' => 'The quick brown fox jumps over the lazy dog',
); };
ok($@ =~ /^NAME is required/,
    "Constructor correctly failed due to lack of NAME for module");

eval { $mod  = ExtUtils::ModuleMaker->new (
    'NAME'     => 'ABC::XYZ',
    'ABSTRACT' => '123456789012345678901234567890123456789012345',
); };
ok($@ =~ /^ABSTRACTs are limited to 44 characters/,
    "Constructor correctly failed due to ABSTRACT > 44 characters");

eval { $mod  = ExtUtils::ModuleMaker->new (
    'NAME'     => 'ABC::XYZ',
    'AUTHOR'   => { 
                    AUTHOR => 'James E Keenan',
                    CPANID => 'ABCDEFGHIJ',
       },
); };
ok($@ =~ /^CPAN IDs are 3-9 characters/,
    "Constructor correctly failed due to CPANID > 9 characters");

eval { $mod  = ExtUtils::ModuleMaker->new (
    'NAME'     => 'ABC::XYZ',
    'AUTHOR'   => { 
                    AUTHOR => 'James E Keenan',
                    CPANID => 'AB',
       },
); };
ok($@ =~ /^CPAN IDs are 3-9 characters/,
    "Constructor correctly failed due to CPANID < 3 characters");

eval { $mod  = ExtUtils::ModuleMaker->new (
    'NAME'     => 'ABC::XYZ',
    'CPANID'   => 'JKEENAN',
); };
ok($@ =~ /^Dying due to bad input to constructor \(CPANID\):/,
    "Constructor correctly failed; argument must be in 2nd-level hash");

eval { $mod  = ExtUtils::ModuleMaker->new (
    'NAME'     => 'ABC::XYZ',
    'AUTHOR'   => { 
                    AUTHOR => 'James E Keenan',
                    EMAIL  => 'jkeenancpan.org',
       },
); };
ok($@ =~ /^EMAIL addresses need to have an at sign/,
    "Constructor correctly failed; e-mail must have '\@' sign");

eval { $mod  = ExtUtils::ModuleMaker->new (
    'NAME'     => 'ABC::XYZ',
    'AUTHOR'   => { 
                    AUTHOR  => 'James E Keenan',
                    WEBSITE => 'ftp://ftp.perl.org',
       },
); };
ok($@ =~ /^WEBSITEs should start with an "http:" or "https:"/,
    "Constructor correctly failed; websites start 'http' or 'https'");

eval { $mod  = ExtUtils::ModuleMaker->new (
    'NAME'     => 'ABC::XYZ',
    'LICENSE'  => 'dka;fkkj3o9jflvbkja0 lkasd;ldfkJKD38kdd;llk45',
); };
ok($@ =~ /^LICENSE is not recognized/,
    "Constructor correctly failed due to unrecognized LICENSE");


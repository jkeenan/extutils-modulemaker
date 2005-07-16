# t/02_bad constructor.t

use Test::More 
# tests => 14;
qw(no_plan);
use strict;
local $^W = 1;

BEGIN { use_ok( 'ExtUtils::ModuleMaker' ); }
BEGIN { use_ok( 'File::Temp', qw| tempdir |); }
BEGIN { use_ok( 'Cwd' ); }

my $odir = cwd();
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
    'ABSTRACT' => 'The quick brown fox jumps over the lazy dog',
); };
ok($@ =~ /^NAME is required/,
    "Constructor correctly failed due to lack of NAME for module");

eval { $mod  = ExtUtils::ModuleMaker->new (
    'NAME' => 'My::B!ad::Module',
); };
ok($@ =~ /^Module NAME contains illegal characters/,
    "Constructor correctly failed due to illegal characters in module name");

eval { $mod  = ExtUtils::ModuleMaker->new (
    'NAME' => "My'BadModule",
); };
ok($@ =~ /^Module NAME contains illegal characters/,
    "Perl 4-style single-quote path separators no longer supported");

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
ok($@ =~ /^CPANID improper top-level key/,
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

ok(chdir $odir, 'changed back to original directory after testing');

__END__

#eval { $mod  = ExtUtils::ModuleMaker->new (
#    'NAME' => 'Jim',
#    'FIRST' => 'Avery',
#    'SECOND' => 'Keenan',
#); };
#ok($@ =~ /^Dying due to bad input to constructor/,
#    "Constructor correctly failed due to invalid keys");


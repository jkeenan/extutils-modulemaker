# t/21.t
use strict;
local $^W = 1;
use Test::More 
tests =>   10;
# qw(no_plan);
use_ok( 'ExtUtils::ModuleMaker' );
use lib ("./t/testlib");
use _Auxiliary qw(
    _get_realhome
    _get_pseudodir
);

my $realhome = _get_realhome();
local $ENV{HOME} = _get_pseudodir("./t/testlib/pseudohome"); # 2 tests

END { $ENV{HOME} = $realhome; }


my $mod = ExtUtils::ModuleMaker->new(
    NAME => 'Sample::Module' 
);

isa_ok($mod, 'ExtUtils::ModuleMaker');

is($mod->{AUTHOR}, 
    'Hilton Stallone', 
    "personal default for AUTHOR is okay");

is($mod->{CPANID}, 
    'RAMBO', 
    "personal default for CPANID is okay");

is($mod->{ORGANIZATION}, 
    'Parliamentary Pictures', 
    "personal default for ORGANIZATION is okay");

is($mod->{WEBSITE}, 
    'http://parliamentarypictures.com', 
    "personal default for WEBSITE is okay");

is($mod->{EMAIL}, 
    'hiltons@parliamentarypictures.com', 
    "personal default for EMAIL is okay");

is($mod->{CPANID}, 
    'RAMBO', 
    "personal default for CPANID is okay");

# my $dump = $mod->dump_keys_except(qw(LicenseParts USAGE_MESSAGE ));
# print $dump, "\n";


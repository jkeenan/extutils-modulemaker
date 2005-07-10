# t/03_quick.t

use Test::More 
# qw(no_plan);
tests => 26;
use strict;
local $^W = 1;

BEGIN { use_ok( 'ExtUtils::ModuleMaker' ); }
BEGIN { use_ok( 'File::Temp', qw| tempdir |); }

my $tdir = tempdir( CLEANUP => 1);
ok(chdir $tdir, 'changed to temp directory for testing');

###########################################################################

my $mod;

ok($mod  = ExtUtils::ModuleMaker->new ( NAME => 'Sample::Module'),
    "call ExtUtils::ModuleMaker->new for Sample-Module");
    
ok( $mod->complete_build(), 'call complete_build()' );

########################################################################

ok(chdir 'Sample/Module',
    "cd Sample/Module");

for (qw/Changes MANIFEST Makefile.PL LICENSE
        README lib t/) {
    ok (-e,
        "$_ exists");
}

########################################################################

my $filetext;
{
    local *FILE;
    ok(open (FILE, 'LICENSE'),
        "reading 'LICENSE'");
    $filetext = do {local $/; <FILE>};
    close FILE;
}

ok($filetext =~ m/Terms of Perl itself/,
    "correct LICENSE generated");

########################################################################

# tests of inheritability of constructor
# note:  attributes must not be thought of as inherited because
# constructor freshly repopulates data structure with default values

my ($modparent, $modchild, $modgrandchild);

ok($modparent  = ExtUtils::ModuleMaker->new(
    NAME => 'Sample::Module',
    ABSTRACT => 'The quick brown fox'
), "call ExtUtils::ModuleMaker->new for Sample-Module");
isa_ok($modparent, "ExtUtils::ModuleMaker", "object is an EU::MM object");
is($modparent->{NAME}, 'Sample::Module', "NAME is correct");
is($modparent->{ABSTRACT}, 'The quick brown fox', "ABSTRACT is correct");

$modchild = $mod->new(
    'NAME'     => 'Alpha::Beta',
);
isa_ok($modchild, "ExtUtils::ModuleMaker", "constructor is inheritable");
is($modchild->{NAME}, 'Alpha::Beta', "new NAME is correct");
isnt($modchild->{ABSTRACT}, 'The quick brown fox', 
    "ABSTRACT was correctly not inherited; constructor used defaults");

ok($modgrandchild  = $modchild->new(
    NAME => 'Gamma::Delta',
    ABSTRACT => 'The quick brown fox'
), "call ExtUtils::ModuleMaker->new for Sample-Module");
isa_ok($modgrandchild, "ExtUtils::ModuleMaker", "object is an EU::MM object");
is($modgrandchild->{NAME}, 'Gamma::Delta', "NAME is correct");
is($modgrandchild->{ABSTRACT}, 'The quick brown fox', 
    "explicitly coded ABSTRACT is correct");

__END__

my $stepchild;

#ok($stepchild  = ExtUtils::ModuleMaker::new(
$stepchild  = ExtUtils::ModuleMaker::new(
    'ExtUtils::ModuleMaker',
    NAME => 'Sample::Module',
    ABSTRACT => 'The quick brown fox'
#), "call ExtUtils::ModuleMaker->new for Sample-Module");
);
#isa_ok($stepchild, "ExtUtils::ModuleMaker", "object is an EU::MM object");
#is($stepchild->{NAME}, 'Sample::Module', "NAME is correct");
#is($stepchild->{ABSTRACT}, 'The quick brown fox', "ABSTRACT is correct");


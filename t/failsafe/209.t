# t/failsafe/209.t
use strict;
local $^W = 1;
use Test::More tests => 12;
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(failsafe) ); 

SKIP: {
    eval { require 5.006_001 };
    skip "failsafe requires File::Temp, core with Perl 5.6", 
        (12 - 2) if $@;
    use warnings;
    my $caller = 'ExtUtils::ModuleMaker';

failsafe($caller,  [
        'NAME'     => 'ABC::XYZ',
        'AUTHOR'   => 'James E Keenan',
        'EMAIL'    => 'jkeenancpan.org',
    ], 
    "^EMAIL addresses need to have an at sign",
    "Constructor correctly failed; e-mail must have '\@' sign"
);

} # end SKIP block


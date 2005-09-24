# t/failsafe/203.t
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

failsafe($caller,  
    [ 'ABSTRACT' => 'The quick brown fox jumps over the lazy dog', ], 
    "^NAME is required",
    "Constructor correctly failed due to lack of NAME for module"
);

} # end SKIP block


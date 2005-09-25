# t/failsafe/211.t
use strict;
local $^W = 1;
use Test::More tests => 12;
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
    failsafe
    _save_pretesting_status
    _restore_pretesting_status
) ); 

my $statusref = _save_pretesting_status();

SKIP: {
    eval { require 5.006_001 };
    skip "failsafe requires File::Temp, core with Perl 5.6", 
        (12 - 2) if $@;
    use warnings;
    my $caller = 'ExtUtils::ModuleMaker';

    failsafe($caller,  [
            'NAME'     => 'ABC::XYZ',
            'LICENSE'  => 'dka;fkkj3o9jflvbkja0 lkasd;ldfkJKD38kdd;llk45',
        ], 
        "^LICENSE is not recognized",
        "Constructor correctly failed due to unrecognized LICENSE"
    );

} # end SKIP block

END {
    _restore_pretesting_status($statusref);
}


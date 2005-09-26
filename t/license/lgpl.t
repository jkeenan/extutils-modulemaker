# t/license/lgpl.t
use strict;
local $^W = 1;
use Test::More tests =>  16;
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::Licenses::Local' );
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
        _save_pretesting_status
        _restore_pretesting_status
        licensetest
    )
);

my $statusref = _save_pretesting_status();

SKIP: {
    eval { require 5.006_001 };
    skip "tests require File::Temp, core with 5.6", 
        (16 - 3) if $@;
    use warnings;

    my $caller = 'ExtUtils::ModuleMaker';
    licensetest($caller,
        'lgpl',
        qr/The GNU Lesser General Public License \(LGPL\)\s+Version 2\.1, February 1999/s
    );
} # end SKIP block

END {
    _restore_pretesting_status($statusref);
}

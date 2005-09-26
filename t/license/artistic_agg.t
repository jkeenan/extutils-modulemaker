# t/license/artistic_agg.t
use strict;
local $^W = 1;
use Test::More tests => 17;
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
        (17 - 3) if $@;
    use warnings;

    my $caller = 'ExtUtils::ModuleMaker';
    licensetest($caller,
        'artistic_agg',
        qr/The Artistic License.*Preamble.*Aggregation of this Package with a commercial distribution/s
    );

    ok(chdir $statusref->{cwd},
        "changed back to original directory");
} # end SKIP block

END {
    _restore_pretesting_status($statusref);
}


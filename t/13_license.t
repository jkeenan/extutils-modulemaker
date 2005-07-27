# t/13_license.t

use Test::More qw(no_plan);;
use strict;
local $^W = 1;

BEGIN { use_ok( 'ExtUtils::ModuleMaker' ); }
use lib ("./t/testlib");
use _Auxiliary qw(
    licensetest
);

licensetest(
    'perl',
    qr/Terms of Perl itself.*GNU General Public License.*Artistic License/s
);

licensetest(
    'apache',
    qr/Apache Software License/s
);

licensetest(
    'apache_1_1',
    qr/Apache Software License.*Version 1\.1/s
);

licensetest(
    'artistic',
    qr/The Artistic License.*Preamble/s
);

licensetest(
    'artistic_agg',
    qr/The Artistic License.*Preamble.*Aggregation of this Package with a commercial distribution/s
);

licensetest(
    'r_bsd',
    qr/The BSD License\s+The following/s
);

licensetest(
    'bsd',
    qr/The BSD License\s+Copyright/s
);

licensetest(
    'gpl',
    qr/The General Public License \(GPL\)\s+Version 2, June 1991/s
);

licensetest(
    'gpl_2',
    qr/The General Public License \(GPL\)\s+Version 2, June 1991/s
);

licensetest(
    'ibm',
    qr/IBM Public License Version \(1\.0\)/s
);

licensetest(
    'ibm_1_0',
    qr/IBM Public License Version \(1\.0\)/s
);

licensetest(
    'intel',
    qr/The Intel Open Source License for CDSA\/CSSM Implementation\s+\(BSD License with Export Notice\)/s
);

licensetest(
    'jabber',
    qr/Jabber Open Source License \(Version 1\.0\)/s
);

licensetest(
    'jabber_1_0',
    qr/Jabber Open Source License \(Version 1\.0\)/s
);

licensetest(
    'lgpl',
    qr/The GNU Lesser General Public License \(LGPL\)\s+Version 2\.1, February 1999/s
);

licensetest(
    'lgpl_2_1',
    qr/The GNU Lesser General Public License \(LGPL\)\s+Version 2\.1, February 1999/s
);

licensetest(
    'mit',
    qr/The MIT License\s+Copyright/s
);

licensetest(
    'mitre',
    qr/MITRE Collaborative Virtual Workspace License \(CVW License\)/s
);

licensetest(
    'mozilla',
    qr/Mozilla Public License 1\.1 \(MPL 1\.1\)/s
);

licensetest(
    'mozilla_1_1',
    qr/Mozilla Public License 1\.1 \(MPL 1\.1\)/s
);

licensetest(
    'mozilla_1_0',
    qr/Mozilla Public License \(Version 1\.0\)\s+1\. Definitions\./s
);

licensetest(
    'mpl',
    qr/Mozilla Public License 1\.1 \(MPL 1\.1\)/s
);

licensetest(
    'mpl_1_1',
    qr/Mozilla Public License 1\.1 \(MPL 1\.1\)/s
);

licensetest(
    'mpl_1_0',
    qr/Mozilla Public License \(Version 1\.0\)\s+1\. Definitions\./s
);

licensetest(
    'nethack',
    qr/Nethack General Public License/s
);

licensetest(
    'python',
    qr/Python License\s+CNRI OPEN SOURCE LICENSE AGREEMENT/s
);

licensetest(
    'q',
    qr/The Q Public License\s+Version 1\.0/s
);

licensetest(
    'q_1_0',
    qr/The Q Public License\s+Version 1\.0/s
);

licensetest(
    'sun',
    qr/Sun Internet Standards Source License \(SISSL\)/s
);

licensetest(
    'sissl',
    qr/Sun Internet Standards Source License \(SISSL\)/s
);

licensetest(
    'sleepycat',
    qr/The Sleepycat License/s
);

licensetest(
    'zlib',
    qr/The zlib\/libpng License/s
);

licensetest(
    'libpng',
    qr/The zlib\/libpng License/s
);

#licensetest(
#    'nokia',
#    qr/Nokia Open Source License \(NOKOS License\) Version 1\.0a/s
#);

#{
#use File::Temp qw| tempdir |;
#use Cwd;
#*ok = *Test::More::ok;
#*is = *Test::More::is;
#*like = *Test::More::like;
##    my ($license, $pattern) = @_;
#    my ($license, $pattern) = ('nokia', qr/Nokia Open Source License \(NOKOS License\) Version 1\.0a/s);
#    my $odir = cwd();
#    my ($tdir, $mod);
#    $tdir = tempdir( CLEANUP => 1);
#    ok(chdir $tdir, "changed to temp directory for testing $license");
#    ok($mod = ExtUtils::ModuleMaker->new(
#        NAME      => "Alpha::$license",
#        LICENSE   => $license,
#        COMPACT   => 1,
#    ), "object for module Alpha::$license created");
##    ok( $mod->complete_build(), 'call complete_build()' );
##    ok(chdir "Alpha-$license", "changed to Alpha-$license directory");
##    my $licensetext = read_file_string('LICENSE');
##    like($licensetext, $pattern, "$license license has predicted content");
#    ok(chdir $odir, 'changed back to original directory after testing');
#}
__END__

# nokia/nokos throwing warning of uninitialized value at Standard line
# 4836
#licensetest(
#    'nokia',
#    qr/Nokia Open Source License \(NOKOS License\) Version 1\.0a/s
#);
#
#licensetest(
#    'nokos',
#    qr/Nokia Open Source License \(NOKOS License\) Version 1\.0a/s
#);
#
#licensetest(
#    'nokia_1_0a',
#    qr/Nokia Open Source License \(NOKOS License\) Version 1\.0a/s
#);
#
#licensetest(
#    'nokos_1_0a',
#    qr/Nokia Open Source License \(NOKOS License\) Version 1\.0a/s
#);

# ricoh & ricoh_1_0 throwing warning:
# Use of uninitialized value in concatenation (.) or string at blib\lib/ExtUtils/ModuleMaker/Licenses/Standard.pm line 5596.
#licensetest(
#    'ricoh',
#    qr/Ricoh Source Code Public License \(Version 1\.0\)/s
#);
#
#licensetest(
#    'ricoh_1_0',
#    qr/Ricoh Source Code Public License \(Version 1\.0\)/s
#);

# vovida & vovida_1_0 throwing warning:
# Use of uninitialized value in concatenation (.) or string at blib\lib/ExtUtils/ModuleMaker/Licenses/Standard.pm line 6653.
#licensetest (
#    'vovida',
#    qr/Vovida Software License v\. 1\.0/s
#);

#licensetest(
#    'vovida_1_0',
#    qr//s
#);


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

#licensetest(
#    'artisticA',
#    qr/The Artistic License.*Preamble.*Aggregation of this Package with a commercial distribution/s
#);

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

#licensetest(
#    '',
#    qr//s
#);

#licensetest(
#    '',
#    qr//s
#);
#
#licensetest(
#    '',
#    qr//s
#);
#
#licensetest(
#    '',
#    qr//s
#);
#
#licensetest(
#    '',
#    qr//s
#);
#
#licensetest(
#    '',
#    qr//s
#);
#
#licensetest(
#    '',
#    qr//s
#);
#
#licensetest(
#    '',
#    qr//s
#);
#
#licensetest(
#    '',
#    qr//s
#);
#
#licensetest(
#    '',
#    qr//s
#);
#
#licensetest(
#    '',
#    qr//s
#);
#

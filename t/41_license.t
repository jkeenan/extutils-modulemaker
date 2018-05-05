# t/license.t
use strict;
use warnings;
use Test::More;
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::Licenses::Standard' );
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw( licensetest ) );


{   # apache
    licensetest( 'ExtUtils::ModuleMaker', 'apache',
        qr/Apache Software License/s );
}

{   # apache_1_1
    licensetest( 'ExtUtils::ModuleMaker', 'apache_1_1',
        qr/Apache Software License.*Version 1\.1/s );
}

{   # artistic
    licensetest( 'ExtUtils::ModuleMaker', 'artistic',
        qr/The Artistic License.*Preamble/s );
}

{   # artistic_agg
    licensetest( 'ExtUtils::ModuleMaker', 'artistic_agg',
        qr/The Artistic License.*Preamble.*Aggregation of this Package with a commercial distribution/s );
}

{   # bsd
    licensetest( 'ExtUtils::ModuleMaker', 'bsd',
        qr/The BSD License\s+Copyright/s );
}

{   # gpl
    licensetest( 'ExtUtils::ModuleMaker', 'gpl',
        qr/The General Public License \(GPL\)\s+Version 2, June 1991/s );
}

{   # gpl_2
    licensetest( 'ExtUtils::ModuleMaker', 'gpl_2',
        qr/The General Public License \(GPL\)\s+Version 2, June 1991/s );
}

{   # ibm
    licensetest( 'ExtUtils::ModuleMaker', 'ibm',
        qr/IBM Public License Version \(1\.0\)/s );
}

{   # ibm_1_0
    licensetest( 'ExtUtils::ModuleMaker', 'ibm_1_0',
        qr/IBM Public License Version \(1\.0\)/s );
}

{   # intel
    licensetest( 'ExtUtils::ModuleMaker', 'intel',
        qr/The Intel Open Source License for CDSA\/CSSM Implementation\s+\(BSD License with Export Notice\)/s );
}

{   # jabber
    licensetest( 'ExtUtils::ModuleMaker', 'jabber',
        qr/Jabber Open Source License \(Version 1\.0\)/s );
}

{   # jabber_1_0
    licensetest( 'ExtUtils::ModuleMaker', 'jabber_1_0',
        qr/Jabber Open Source License \(Version 1\.0\)/s );
}

{   # lgpl
    licensetest( 'ExtUtils::ModuleMaker', 'lgpl',
        qr/The GNU Lesser General Public License \(LGPL\)\s+Version 2\.1, February 1999/s );
}

{   # lgpl_2_1
    licensetest( 'ExtUtils::ModuleMaker', 'lgpl_2_1',
        qr/The GNU Lesser General Public License \(LGPL\)\s+Version 2\.1, February 1999/s );
}

{   # libpng
    licensetest( 'ExtUtils::ModuleMaker', 'libpng',
        qr/The zlib\/libpng License/s );
}

{   # mit
    licensetest( 'ExtUtils::ModuleMaker', 'mit',
        qr/The MIT License\s+Copyright/s );
}

{   # mitre
    licensetest( 'ExtUtils::ModuleMaker', 'mitre',
        qr/MITRE Collaborative Virtual Workspace License \(CVW License\)/s );
}

{   # mozilla
    licensetest( 'ExtUtils::ModuleMaker', 'mozilla',
        qr/Mozilla Public License 1\.1 \(MPL 1\.1\)/s );
}

{   # mozilla_1_0
    licensetest( 'ExtUtils::ModuleMaker', 'mozilla_1_0',
        qr/Mozilla Public License \(Version 1\.0\)\s+1\. Definitions\./s );
}

{   # mozilla_1_1
    licensetest( 'ExtUtils::ModuleMaker', 'mozilla_1_1',
        qr/Mozilla Public License 1\.1 \(MPL 1\.1\)/s );
}

{   # mpl
    licensetest( 'ExtUtils::ModuleMaker', 'mpl',
        qr/Mozilla Public License 1\.1 \(MPL 1\.1\)/s );
}

{   # mpl_1_0
    licensetest( 'ExtUtils::ModuleMaker', 'mpl_1_0',
        qr/Mozilla Public License \(Version 1\.0\)\s+1\. Definitions\./s );
}

{   # mpl_1_1
    licensetest( 'ExtUtils::ModuleMaker', 'mpl_1_1',
        qr/Mozilla Public License 1\.1 \(MPL 1\.1\)/s );
}

{   # nethack
    licensetest( 'ExtUtils::ModuleMaker', 'nethack',
        qr/Nethack General Public License/s );
}

{   # nokia
    licensetest( 'ExtUtils::ModuleMaker', 'nokia',
        qr/Nokia Open Source License \(NOKOS License\) Version 1\.0a/s );
}

{   # nokia_1_0a
    licensetest( 'ExtUtils::ModuleMaker', 'nokia_1_0a',
        qr/Nokia Open Source License \(NOKOS License\) Version 1\.0a/s );
}

{   # nokos
    licensetest( 'ExtUtils::ModuleMaker', 'nokos',
        qr/Nokia Open Source License \(NOKOS License\) Version 1\.0a/s );
}

{   # nokos_1_0a
    licensetest( 'ExtUtils::ModuleMaker', 'nokos_1_0a',
        qr/Nokia Open Source License \(NOKOS License\) Version 1\.0a/s );
}

{   # perl
    licensetest( 'ExtUtils::ModuleMaker', 'perl',
        qr/Terms of Perl itself.*GNU General Public License.*Artistic License/s );
}

{   # python
    licensetest( 'ExtUtils::ModuleMaker', 'python',
        qr/Python License\s+CNRI OPEN SOURCE LICENSE AGREEMENT/s );
}

{   # q
    licensetest( 'ExtUtils::ModuleMaker', 'q',
        qr/The Q Public License\s+Version 1\.0/s );
}

{   # q_1_0
    licensetest( 'ExtUtils::ModuleMaker', 'q_1_0',
        qr/The Q Public License\s+Version 1\.0/s );
}

{   # r_bsd
    licensetest( 'ExtUtils::ModuleMaker', 'r_bsd',
        qr/The BSD License\s+The following/s );
}

{   # ricoh
    licensetest( 'ExtUtils::ModuleMaker', 'ricoh',
        qr/Ricoh Source Code Public License \(Version 1\.0\)/s );
}

{   # ricoh_1_0
    licensetest( 'ExtUtils::ModuleMaker', 'ricoh_1_0',
        qr/Ricoh Source Code Public License \(Version 1\.0\)/s );
}

{   # sissl
    licensetest( 'ExtUtils::ModuleMaker', 'sissl',
        qr/Sun Internet Standards Source License \(SISSL\)/s );
}

{   # sleepycat
    licensetest( 'ExtUtils::ModuleMaker', 'sleepycat',
        qr/The Sleepycat License/s );
}

{   # sun
    licensetest( 'ExtUtils::ModuleMaker', 'sun',
        qr/Sun Internet Standards Source License \(SISSL\)/s );
}

{   # vovida
    licensetest( 'ExtUtils::ModuleMaker', 'vovida',
        qr/Vovida Software License v\. 1\.0/s );
}

{   # vovida_1_0
    licensetest( 'ExtUtils::ModuleMaker', 'vovida_1_0',
        qr//s );
}

{   # zlib
    licensetest( 'ExtUtils::ModuleMaker', 'zlib',
        qr/The zlib\/libpng License/s );
}

my $self = ExtUtils::ModuleMaker::Licenses::Standard->interact();
isa_ok($self, 'ExtUtils::ModuleMaker::Licenses::Standard');

my %licenses = ExtUtils::ModuleMaker::Licenses::Standard::Custom_Licenses();
like($licenses{COPYRIGHT}, qr/The full text/s, "Custom_Licenses() returned expected text");

done_testing();


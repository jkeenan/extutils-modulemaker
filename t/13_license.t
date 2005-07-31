# t/13_license.t

use Test::More tests => 271;
use strict;

BEGIN {
    use_ok( 'ExtUtils::ModuleMaker' );
    use_ok( 'ExtUtils::ModuleMaker::Licenses::Local' );
    use_ok( 'Cwd' );
}

SKIP: {
    eval { require 5.006_001 };
    skip "tests require File::Temp, core with 5.6", 268 if $@;
    use warnings;
    use_ok( 'File::Temp', qw| tempdir |);
    use lib ("./t/testlib");
    use _Auxiliary qw(
        licensetest
        read_file_string
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

    licensetest(
        'nokia',
        qr/Nokia Open Source License \(NOKOS License\) Version 1\.0a/s
    );

    licensetest(
        'nokos',
        qr/Nokia Open Source License \(NOKOS License\) Version 1\.0a/s
    );

    licensetest(
        'nokia_1_0a',
        qr/Nokia Open Source License \(NOKOS License\) Version 1\.0a/s
    );

    licensetest(
        'nokos_1_0a',
        qr/Nokia Open Source License \(NOKOS License\) Version 1\.0a/s
    );

    licensetest(
        'ricoh',
        qr/Ricoh Source Code Public License \(Version 1\.0\)/s
    );

    licensetest(
        'ricoh_1_0',
        qr/Ricoh Source Code Public License \(Version 1\.0\)/s
    );

    licensetest (
        'vovida',
        qr/Vovida Software License v\. 1\.0/s
    );

    licensetest(
        'vovida_1_0',
        qr//s
    );

    my $odir = cwd();
    my ($tdir, $mod, $testmod, $filetext, $license);

    {
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');
        $testmod = 'Beta';

        ok($mod = ExtUtils::ModuleMaker->new( 
                NAME           => "Alpha::$testmod",
                COMPACT        => 1,
                LICENSE        => 'looselips',
    	    COPYRIGHT_YEAR => 1899,
    	    AUTHOR => {
    		    NAME => "J E Keenan", 
    		    ORGANIZATION => "The World Wide Webby",
    	    },
        ), "object created for Alpha::$testmod");
        ok($mod->complete_build(), "build files for Alpha::$testmod");

        ok( -d qq{Alpha-$testmod}, "compact top-level directory exists" );
        ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );
        ok( -d, "directory $_ exists" ) for ( qw/lib scripts t/);
        ok( -f, "file $_ exists" )
            for ( qw/Changes LICENSE Makefile.PL MANIFEST README Todo/);
        ok( -f, "file $_ exists" )
            for ( "lib/Alpha/${testmod}.pm", "t/001_load.t" );
        
        ok($filetext = read_file_string('LICENSE'),
            'Able to read LICENSE');
        
        like($filetext,
            qr/Copyright \(c\) 1899 The World Wide Webby\. All rights reserved\./, 
            "correct copyright year and organization"
        );
        ok($license = $mod->get_license(), "license retrieved"); 
        like($license,
            qr/^={69}\s+={69}.*?={69}\s+={69}.*?={69}\s+={69}/s,
            "formatting for license and copyright found as expected"
        );

        ok(chdir $odir, 'changed back to original directory after testing');
    }

} # end SKIP block


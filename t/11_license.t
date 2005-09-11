# t/11_license.t
use strict;
local $^W = 1;
use Test::More 
tests =>  561;
# qw(no_plan);
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::Licenses::Local' );
use_ok( 'Cwd');
use_ok( 'ExtUtils::ModuleMaker::Utility', qw( 
        _preexists_mmkr_directory
        _make_mmkr_directory
        _restore_mmkr_dir_status
    )
);


SKIP: {
    eval { require 5.006_001 };
    skip "tests require File::Temp, core with 5.6", 
        (561 - 3) if $@;
    use warnings;
    use_ok( 'File::Temp', qw| tempdir |);
    use ExtUtils::ModuleMaker::Auxiliary qw(
        licensetest
        read_file_string
    );

    my $caller = 'ExtUtils::ModuleMaker';

    licensetest($caller,
        'perl',
        qr/Terms of Perl itself.*GNU General Public License.*Artistic License/s
    );

    licensetest($caller,
        'apache',
        qr/Apache Software License/s
    );

    licensetest($caller,
        'apache_1_1',
        qr/Apache Software License.*Version 1\.1/s
    );

    licensetest($caller,
        'artistic',
        qr/The Artistic License.*Preamble/s
    );

    licensetest($caller,
        'artistic_agg',
        qr/The Artistic License.*Preamble.*Aggregation of this Package with a commercial distribution/s
    );

    licensetest($caller,
        'r_bsd',
        qr/The BSD License\s+The following/s
    );

    licensetest($caller,
        'bsd',
        qr/The BSD License\s+Copyright/s
    );

    licensetest($caller,
        'gpl',
        qr/The General Public License \(GPL\)\s+Version 2, June 1991/s
    );

    licensetest($caller,
        'gpl_2',
        qr/The General Public License \(GPL\)\s+Version 2, June 1991/s
    );

    licensetest($caller,
        'ibm',
        qr/IBM Public License Version \(1\.0\)/s
    );

    licensetest($caller,
        'ibm_1_0',
        qr/IBM Public License Version \(1\.0\)/s
    );

    licensetest($caller,
        'intel',
        qr/The Intel Open Source License for CDSA\/CSSM Implementation\s+\(BSD License with Export Notice\)/s
    );

    licensetest($caller,
        'jabber',
        qr/Jabber Open Source License \(Version 1\.0\)/s
    );

    licensetest($caller,
        'jabber_1_0',
        qr/Jabber Open Source License \(Version 1\.0\)/s
    );

    licensetest($caller,
        'lgpl',
        qr/The GNU Lesser General Public License \(LGPL\)\s+Version 2\.1, February 1999/s
    );

    licensetest($caller,
        'lgpl_2_1',
        qr/The GNU Lesser General Public License \(LGPL\)\s+Version 2\.1, February 1999/s
    );

    licensetest($caller,
        'mit',
        qr/The MIT License\s+Copyright/s
    );

    licensetest($caller,
        'mitre',
        qr/MITRE Collaborative Virtual Workspace License \(CVW License\)/s
    );

    licensetest($caller,
        'mozilla',
        qr/Mozilla Public License 1\.1 \(MPL 1\.1\)/s
    );

    licensetest($caller,
        'mozilla_1_1',
        qr/Mozilla Public License 1\.1 \(MPL 1\.1\)/s
    );

    licensetest($caller,
        'mozilla_1_0',
        qr/Mozilla Public License \(Version 1\.0\)\s+1\. Definitions\./s
    );

    licensetest($caller,
        'mpl',
        qr/Mozilla Public License 1\.1 \(MPL 1\.1\)/s
    );

    licensetest($caller,
        'mpl_1_1',
        qr/Mozilla Public License 1\.1 \(MPL 1\.1\)/s
    );

    licensetest($caller,
        'mpl_1_0',
        qr/Mozilla Public License \(Version 1\.0\)\s+1\. Definitions\./s
    );

    licensetest($caller,
        'nethack',
        qr/Nethack General Public License/s
    );

    licensetest($caller,
        'python',
        qr/Python License\s+CNRI OPEN SOURCE LICENSE AGREEMENT/s
    );

    licensetest($caller,
        'q',
        qr/The Q Public License\s+Version 1\.0/s
    );

    licensetest($caller,
        'q_1_0',
        qr/The Q Public License\s+Version 1\.0/s
    );

    licensetest($caller,
        'sun',
        qr/Sun Internet Standards Source License \(SISSL\)/s
    );

    licensetest($caller,
        'sissl',
        qr/Sun Internet Standards Source License \(SISSL\)/s
    );

    licensetest($caller,
        'sleepycat',
        qr/The Sleepycat License/s
    );

    licensetest($caller,
        'zlib',
        qr/The zlib\/libpng License/s
    );

    licensetest($caller,
        'libpng',
        qr/The zlib\/libpng License/s
    );

    licensetest($caller,
        'nokia',
        qr/Nokia Open Source License \(NOKOS License\) Version 1\.0a/s
    );

    licensetest($caller,
        'nokos',
        qr/Nokia Open Source License \(NOKOS License\) Version 1\.0a/s
    );

    licensetest($caller,
        'nokia_1_0a',
        qr/Nokia Open Source License \(NOKOS License\) Version 1\.0a/s
    );

    licensetest($caller,
        'nokos_1_0a',
        qr/Nokia Open Source License \(NOKOS License\) Version 1\.0a/s
    );

    licensetest($caller,
        'ricoh',
        qr/Ricoh Source Code Public License \(Version 1\.0\)/s
    );

    licensetest($caller,
        'ricoh_1_0',
        qr/Ricoh Source Code Public License \(Version 1\.0\)/s
    );

    licensetest($caller,
        'vovida',
        qr/Vovida Software License v\. 1\.0/s
    );

    licensetest($caller,
        'vovida_1_0',
        qr//s
    );

    my $odir = cwd();
    my ($tdir, $mod, $testmod, $filetext, $license);

    {
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        $testmod = 'Beta';

        ok($mod = ExtUtils::ModuleMaker->new( 
                NAME           => "Alpha::$testmod",
                COMPACT        => 1,
                LICENSE        => 'looselips',
    	    COPYRIGHT_YEAR => 1899,
    	    AUTHOR => "J E Keenan", 
    		ORGANIZATION => "The World Wide Webby",
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

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");

    }

} # end SKIP block


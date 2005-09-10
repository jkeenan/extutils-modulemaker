package ExtUtils::ModuleMaker;
use strict;
local $^W = 1;
BEGIN {
    use vars qw( $VERSION @ISA ); 
    $VERSION = '0.39_04';
    use base qw(
        ExtUtils::ModuleMaker::Defaults
        ExtUtils::ModuleMaker::Initializers
        ExtUtils::ModuleMaker::StandardText
    );
};
use ExtUtils::ModuleMaker::Utility qw( 
    _preexists_mmkr_directory
    _make_mmkr_directory
);
use Carp;
use File::Path;
use File::Spec;
# use Data::Dumper;
use Cwd;

#################### PUBLICLY CALLABLE METHODS ####################

sub new {
    my $class = shift;

    my $self = ref($class) ? bless( {}, ref($class) )
                           : bless( {}, $class );

    # multi-stage initialization of EU::MM object
    
    # 1. Determine if there already exists on system a directory capable of
    # holding user ExtUtils::ModuleMaker::Personal::Defaults.  The name of
    # such a directory and whether it exists at THIS point are stored in an
    # array, a reference to which is the return value of
    # _preexists_mmkr_directory and which is then stored in the object.
    # NOTE:  If the directory does not yet exists, it is not automatically
    # created.
    $self->{mmkr_dir_ref} =  _preexists_mmkr_directory();
    {
        my $mmkr_dir = $self->{mmkr_dir_ref}->[0];
        if (defined $self->{mmkr_dir_ref}->[1]) {
            push @INC, $mmkr_dir;
        }
        my $pers_file = File::Spec->catfile( $mmkr_dir,
            qw| ExtUtils ModuleMaker Personal Defaults.pm |
        );
        if (-f $pers_file) {
            require ExtUtils::ModuleMaker::Personal::Defaults;
            unshift @ISA, qw(ExtUtils::ModuleMaker::Personal::Defaults);
        }
    }

    # 2.  Populate object with default values.
    my $defaults_ref;
    $defaults_ref = $self->default_values();
    foreach my $def ( keys %{$defaults_ref} ) {
        $self->{$def} = $defaults_ref->{$def};
    }
    
    # 3.  Pull in arguments supplied to constructor.
    # These will come from one of three sources:
    # a.  In a script, KEY => 'Value' pairs supplied to new();
    # b.  From modulemaker command-line, -option 'Value' pairs following
    # 'modulemaker';
    # c.  From modulemaker interactive mode, hard-wired values which may
    # supersede (b) values.
    # NOTE:  *Any* values coming in here will supersede the defaults
    # established above, whether those defaults came from EU::MM::Defaults or
    # from EU::MM::Personal::Defaults somewhere on system.
    my @arglist = @_;
    croak "Must be hash or balanced list of key-value pairs: $!"
        if (@arglist % 2);
    my %parameters = @arglist;

    # 4.  Process key-value pairs supplied as arguments to new() either
    # from user-written program or from modulemaker utility.
    # These override default values (or may provide additional elements).
    foreach my $param ( keys %parameters ) {
        $self->{$param} = $parameters{$param};
    }

    # 5.  Initialize keys set from information supplied above, system
    # info or EU::MM itself.
    $self->set_author_composite();
    $self->set_dates();
    $self->{eumm_version} = $VERSION;
    $self->{MANIFEST} = ['MANIFEST'];

    # 6.  Validate values supplied so far to weed out most likely errors
    $self->validate_values();

    # 7.  Initialize keys set from EU::MM::Licenses::Local or
    # EU::MM::Licenses::Standard
    $self->initialize_license();

    # 8.  Any EU::MM methods stored in ExtUtils::ModuleMaker::Standard Text i
    # can be overriden by supplying a
    # value for ALT_BUILD (command-line option 'd') where the value is a Perl
    # module located in @INC
    if (defined $self->{ALT_BUILD}) {
        my $alt_build = $self->{ALT_BUILD};
        unless ($alt_build =~ m{^ExtUtils::ModuleMaker::}) {
            $alt_build = q{ExtUtils::ModuleMaker::} . $alt_build;
        }
        eval "require $alt_build";
        if ($@) {
            croak "Unable to locate $alt_build for alternative methods: $!";
        } else {
            unshift @ISA, $alt_build;
        };
    }
    return $self;
}

sub complete_build {
    my $self = shift;

    $self->create_base_directory();
    $self->check_dir( map
        { File::Spec->catdir( $self->{Base_Dir}, $_ ) }
        qw (lib t scripts) );

    $self->print_file( 'LICENSE', $self->{LicenseParts}{LICENSETEXT} );
    $self->print_file( 'README',  $self->text_README() );
    $self->print_file( 'Todo',    $self->text_Todo() )
#        if $self->text_Todo();
        if $self->{INCLUDE_TODO};
    $self->print_file( 'MANIFEST.SKIP', $self->text_MANIFEST_SKIP() )
        if $self->{INCLUDE_MANIFEST_SKIP};

    unless ( $self->{CHANGES_IN_POD} ) {
        $self->print_file( 'Changes', $self->text_Changes() );
    }

    my @pmfiles = ( $self );
    foreach my $f ( @{ $self->{EXTRA_MODULES} } ) {
        push @pmfiles, $f;
    }
    foreach my $module ( @pmfiles ) {
        $self->generate_pm_file($module);
    }
    unless ($self->{EXTRA_MODULES_SINGLE_TEST_FILE}) {
        my $ct = $self->{FIRST_TEST_NUMBER};
        foreach my $module ( @pmfiles ) {
            my ($teststart, $testmiddle);
            if (defined $self->{TEST_NUMBER_FORMAT}) {
                $teststart = "t/" . $self->{TEST_NUMBER_FORMAT} .
                    $self->{TEST_NAME_SEPARATOR};
            } else {
                $teststart = "t/";
            }
            if ($self->{TEST_NAME_DERIVED_FROM_MODULE_NAME}) {
                $testmiddle = $self->module_value( $module, 'NAME' );
                $testmiddle =~ s|::|$self->{TEST_NAME_SEPARATOR}|g;
            } else {
                $testmiddle = $self->{TEST_NAME};
            }
            my $testfilename = sprintf( $teststart . $testmiddle . q{.t}, $ct );
            $self->print_file( $testfilename,
                $self->text_test( $testfilename, $module ) );
            $ct++;
        }
    } else {
        my $teststart;
        if (defined $self->{TEST_NUMBER_FORMAT}) {
            $teststart = "t/" . $self->{TEST_NUMBER_FORMAT} .
                $self->{TEST_NAME_SEPARATOR};
        } else {
            $teststart = "t/";
        }
        my $testfilename = sprintf( $teststart . $self->{TEST_NAME} . q{.t}, 
            $self->{FIRST_TEST_NUMBER});
        $self->print_file( $testfilename,
            $self->text_test_multi( $testfilename, \@pmfiles ) );
    }

    #Makefile must be created after generate_pm_file which sets $self->{FILE}
    if ( $self->{BUILD_SYSTEM} eq 'ExtUtils::MakeMaker' ) {
        $self->print_file( 'Makefile.PL', $self->text_Makefile() );
    }
    else {
        $self->print_file( 'Build.PL', $self->text_Buildfile() );
        if ( $self->{BUILD_SYSTEM} eq 'Module::Build and proxy Makefile.PL' 
         or  $self->{BUILD_SYSTEM} eq 'Module::Build and Proxy') {
            $self->print_file( 'Makefile.PL',
                $self->text_proxy_makefile() );
        }
    }

    $self->print_file( 'MANIFEST', join( "\n", @{ $self->{MANIFEST} } ) );
    $self->make_selections_defaults() if $self->{SAVE_AS_DEFAULTS};
    return 1;
}

sub dump_keys {
    my $self = shift;
    my %keys_to_be_shown = map {$_, 1} @_;
    require Data::Dumper;
    my ($k, $v, %retry);
    while ( ($k, $v) = each %{$self} ) {
        $retry{$k} = $v if $keys_to_be_shown{$k};
    }
    my $d = Data::Dumper->new( [\%retry] );
    return $d->Dump;
}

sub dump_keys_except {
    my $self = shift;
    my %keys_not_shown = map {$_, 1} @_;
    require Data::Dumper;
    my ($k, $v, %retry);
    while ( ($k, $v) = each %{$self} ) {
        $retry{$k} = $v unless $keys_not_shown{$k};
    }
    my $d = Data::Dumper->new( [\%retry] );
    return $d->Dump;
}

sub get_license {
    my $self = shift;
    return (join ("\n\n",
        "=====================================================================",
        "=====================================================================",
        $self->{LicenseParts}{LICENSETEXT},
        "=====================================================================",
        "=====================================================================",
        $self->{LicenseParts}{COPYRIGHT},
        "=====================================================================",
        "=====================================================================",
    ));
}

sub make_selections_defaults {
    my $self = shift;
    my %selections = %{$self};
    my @dv = keys %{ $self->default_values() };
    my $topfile = <<'END_TOPFILE';
package ExtUtils::ModuleMaker::Personal::Defaults;
use strict;

my %default_values = (
END_TOPFILE
    
my @keys_needed;
for my $k (@dv) {
    push @keys_needed, $k
        unless ($k eq 'ABSTRACT' or $k eq 'SAVE_AS_DEFAULTS');
}

my $kvpairs;
foreach my $k (@keys_needed) {
    $kvpairs .=
        (' ' x 8) . (sprintf '%-16s', $k) . '=> q{' . $selections{$k} .  "},\n";
}
$kvpairs .= (' ' x 8) . (sprintf '%-16s', 'ABSTRACT') . 
    '=> q{Module abstract (<= 44 characters) goes here}' . "\n";

    my $bottomfile = <<'END_BOTTOMFILE';
);

sub default_values {
    my $self = shift;
    return { %default_values };
}

1;

END_BOTTOMFILE

    my $output =  $topfile . $kvpairs . $bottomfile;

    my $mmkr_dir = _make_mmkr_directory($self->{mmkr_dir_ref});
    my $full_dir = File::Spec->catdir($mmkr_dir,
        qw| ExtUtils ModuleMaker Personal |
    );
    if (! -d $full_dir) {
        mkpath( $full_dir );
        if ($@) {
            croak "Unable to make directory for placement of personal defaults file: $!"; };
    }
    my $pers_full = File::Spec->catfile( $full_dir, q{Defaults.pm} );
    if (-f $pers_full ) {
        my $modtime = (stat($pers_full))[9];
        rename $pers_full,
               "$pers_full.$modtime"
            or croak "Unable to rename $pers_full: $!";
    }
    open my $fh, '>', $pers_full 
        or croak "Unable to open $pers_full for writing: $!";
    print $fh $output or croak "Unable to print $pers_full: $!";
    close $fh or croak "Unable to close $pers_full after writing: $!";
}

1;

#################### DOCUMENTATION ####################

=head1 NAME

ExtUtils::ModuleMaker - Better than h2xs for creating modules

=head1 SYNOPSIS

    use ExtUtils::ModuleMaker;

    $mod = ExtUtils::ModuleMaker->new(
        NAME => 'Sample::Module' 
    );

    $mod->complete_build();

    $mod->dump_keys(qw|
        ...  # key provided as argument to constructor
        ...  # same
    |);

    $mod->dump_keys_except(qw|
        ...  # key provided as argument to constructor
        ...  # same
    |);

    $license = $mod->get_license();

    $mod->make_selections_defaults();

=head1 VERSION

This document references version 0.39_04 of ExtUtils::ModuleMaker, released
to CPAN on September 9, 2005.

=head1 DESCRIPTION

This module is a replacement for the most typical use of the F<h2xs> 
utility bundled with all Perl distributions:  the creation of the 
directories and files required for a pure-Perl module to be distributable 
on the Comprehensive Perl Archive Network (CPAN).

F<h2xs> has many options which are useful -- indeed, necessary -- for 
the creation of a properly structured distribution that includes C code 
as well as Perl code.  Most of the time, however, F<h2xs> is used as follows

    % h2xs -AXn My::Module

to create a distribution containing only Perl code.  ExtUtils::ModuleMaker is 
intended to be an easy-to-use replacement for I<this> use of F<h2xs>.  

While ExtUtils::ModuleMaker can be called from within a Perl script (as in 
the SYNOPSIS above), it is most easily used by a command-prompt invocation 
of the F<modulemaker> script bundled with this distribution:

    % modulemaker

and then responding to the prompts.  For Perl programmers, laziness is a 
virtue -- and F<modulemaker> is the laziest way to create a 
pure Perl distribution which meets all the requirements for worldwide 
distribution via CPAN.

=head1 USAGE

=head2 Usage from the command-line with F<modulemaker>

The easiest way to use ExtUtils::ModuleMaker is to invoke the 
F<modulemaker> script from the command-line.  You can control the content of
the files built by F<modulemaker> either by supplying command-line options or
-- easier still -- replying to the screen prompts in F<modulemaker>'s
interactive mode.  See the documentation for F<modulemaker> bundled with 
this distribution.

=head2 Usage within a Perl script

ExtUtils::ModuleMaker can be used within a Perl script to generate the
directories and files needed to begin work on a CPAN-ready Perl distribution.
You will need to call C<new()> and C<complete_build()>, both of which are
described in the next section.

=head3 Public Methods

In this version of ExtUtils::ModuleMaker there are five publicly 
callable methods.  Two of them, C<new> and C<complete_build> control the
building of the file and directory structure for a new Perl distribution.  
The other three, C<dump_keys>, C<dump_keys_except> and C<get_license> are 
intended primarily as shortcuts for some diagnosing problems with an 
ExtUtils::ModuleMaker object.

=head4 C<new>

Creates and returns an ExtUtils::ModuleMaker object.  Takes a list 
containing key-value pairs with information specifying the
structure and content of the new module(s).  With the exception of 
key EXTRA_MODULES (see below), the values in these pairs 
are all strings.  Like most such lists of key-value pairs, this list 
is probably best held in a hash.   Keys which may be specified are:

=over 4

=item * NAME

The I<only> required feature.  This is the name of the primary module 
(with 'C<::>' separators if needed).  Will no longer support the older,
Perl 4-style separator ''C<'>'' like the module F<D'Oh>.  There is no 
current default for NAME.

=item * ABSTRACT

A short (44-character maximum) description of the module.  CPAN likes 
to use this feature to describe the module.  If the abstract contains an
apostrophe (C<'>), then the value corresponding to key C<ABSTRACT> in
the list passed to the constructor must be double-quoted; otherwise
F<Makefile.PL> gets messed up.

=item * VERSION

A real number to be the version number.  Do not use Linux style numbering 
with multiple dots like 2.4.24.  For alpha releases, include an underscore 
to the right of the dot like 0.31_21. (Default is 0.01.)

=item * LICENSE

Which license to include in the Copyright section.  You can choose one of 
the standard licenses by including 'perl', 'gpl', 'artistic', and 18 others 
approved by opensource.org.  The default is to choose the 'perl' flavor 
which is to share it ''under the same terms as Perl itself.''

Other licenses can be added by individual module authors to 
ExtUtils::ModuleMaker::Licenses::Local to keep your company lawyers happy.

Some licenses include placeholders that will be replaced with AUTHOR 
information.

=item * BUILD_SYSTEM

This can take one of three values:  

=over 4

=item * C<'ExtUtils::MakeMaker'>

The first generates a basic Makefile.PL file for your module.

=item * C<'Module::Build'>

The second creates a Build.PL file.

=item * C<'Module::Build and Proxy'>

The third creates a Build.PL along with a proxy Makefile.PL
script that attempts to install Module::Build if necessary, and then
runs the Build.PL script.  This option is recommended if you want to
use Module::Build as your build system.  See Module::Build::Compat for
more details.

B<Note:>  To correct a discrepancy between the documentation and code in
earlier versions of ExtUtils::ModuleMaker, we now explicitly provide
this synonym for the third option:

    'Module::Build and proxy Makefile.PL'

(Thanks to David A Golden for spotting this bug.)

=back

=item * AUTHOR

Name of the author.  If the author's name contains an apostrophe (C<'>), 
then the corresponding value in the list passed to the constructor must 
be double-quoted; otherwise F<Makefile.PL> gets messed up.

=item * EMAIL

Email address of the author.  If the author's e-mail address contains 
an apostrophe (C<'>), then the corresponding value in the list passed 
to the constructor must be double-quoted; otherwise
F<Makefile.PL> gets messed up.

=item * CPANID

The CPANID of the author.  If this is omitted, then the line will not
be added to the documentation.

=item * WEBSITE

The personal or organizational website of the author.  If this is 
omitted, then the line will not be added to the documentation.

=item * ORGANIZATION

Company or group owning the module.  If this is omitted, then the line 
will not be added to the documentation.

=item * PERSONAL_DEFAULTS_DIR

Location of a directory holding ExtUtils::ModuleMaker::Personal::Defaults.pm.,
whose elements will override those the defaults provided as defaults by 
ExtUtils::ModuleMaker.

=item * EXTRA_MODULES

A reference to an array of hashes, each of which contains values for 
additional modules in the distribution.  As with the primary module 
only NAME is required and primary module values will be used if no 
value is given here.

Each extra module will be created in the correct relative place in the
F<lib> directory.  A test file will also be created in the F<t>
directory corresponding to each extra module to test that it loads
properly.  However, no other supporting documents (I<e.g.,> README, 
Changes) will be created.

This is one major improvement over the earlier F<h2xs> as you can now
build multi-module packages.

=item * COMPACT

For a module named ''Foo::Bar::Baz'' creates a base directory named
''Foo-Bar-Baz'' instead of Foo/Bar/Baz. (Default off)

=item * VERBOSE

Prints messages as it creates directories, writes files, etc. (Default off)

=item * INTERACTIVE

Suppresses 'die' when something goes wrong.  Should only be used by interactive
scripts like F<modulemaker>. (Default off)

=item * PERMISSIONS

Used to create new directories.  (Default is 0755:  group and world can not 
write.)

=item * USAGE_MESSAGE

Message given when the module 'die's.  Scripts should set this to the same 
string it would print if the user asked for help (often with a -h flag).

=item * NEED_POD

Include POD section in modules. (Default is on)

=item * NEED_NEW_METHOD

Include a simple 'new' method in the object oriented module.  (Default is on)

=item * CHANGES_IN_POD

Don't include a 'Changes' file, but instead add a HISTORY section to the POD. 
(Default is off).

=item * ALT_BUILD

Name of Perl package holding methods which override those called withiin
C<complete_build> to shape the content of files created by using
ExtUtils::ModuleMaker.

=back

=head4 C<complete_build>

Creates all directories and files as configured by the key-value pairs
passed to C<ExtUtils::ModuleMaker::new>.  Returns a
true value if all specified files are created -- but this says nothing
about whether those files have been created with the correct content.

=head4 C<dump_keys>

When troubleshooting problems with an ExtUtils::ModuleMaker object, it
is often useful to use F<Data::Dumper> to dump the contents of the
object.  However, since certain elements of that object are often quite
lengthy (I<e.g,> the values of keys C<LicenseParts> and
C<USAGE_MESSAGE>), it's handy to have a dumper function that dumps
C<only> designated keys.

    $mod->dump_keys( qw| NAME ABSTRACT | );

=head4 C<dump_keys_except>

When troubleshooting problems with an ExtUtils::ModuleMaker object, it
is often useful to use F<Data::Dumper> to dump the contents of the
object.  However, since certain elements of that object are often quite
lengthy (I<e.g,> the values of keys C<LicenseParts> and
C<USAGE_MESSAGE>), it's handy to have a dumper function that dumps all
keys I<except> certain designated keys.

    @excluded_keys = qw| LicenseParts USAGE_MESSAGE |;
    $mod->dump_keys_except(@excluded_keys);

=head4 C<get_license>

Returns a string which nicely formats a short version of the License 
and Copyright information.

    $license = $mod->get_license();
    print $license;

... will print something like this:

    =====================================================================
    =====================================================================
    [License Information]
    =====================================================================
    =====================================================================
    [Copyright Information]
    =====================================================================
    =====================================================================

(Earlier versions of ExtUtils::ModuleMaker contained a
C<Display_License> function in each of submodules
F<ExtUtils::ModuleMaker::Licenses::Standard> and
F<ExtUtils::ModuleMaker::Licenses::Local>.  These functions were never
publicly documented or tested.  C<get_license()> is intended as a
replacement for those two functions.)

=head4 C<make_selections_defaults()>

Saves the values you entered as arguments passed to C<new()> in a personal
defaults file so that they supersede the defaults provided by
ExtUtils::ModuleMaker itself.

This is an advanced usage of ExtUtils::ModuleMaker.
If you have used ExtUtils::ModuleMaker more than once, you have probably typed
in a choice for C<AUTHOR>, C<EMAIL>, etc., more than once.  To save
unnecessary typing and reduce typing errors, ExtUtils::ModuleMaker now offers
you the possibility of establishing B<personal default values> which override
the default values supplied with the distribution and found in
F<lib/ExtUtils/ModuleMaker/Defaults.pm>.

Suppose that you have called C<ExtUtils::ModuleMaker::new()> as follows:

    $mod = ExtUtils::ModuleMaker->new(
        NAME            => 'Sample::Module',
        ABSTRACT        => 'Now is the time to join the party',
        AUTHOR          => 'Hilton Stallone',
        CPANID          => 'RAMBO',
        ORGANIZATION    => 'Parliamentary Pictures',
        WEBSITE         => 'http://parliamentarypictures.com',
        EMAIL           => 'hiltons@parliamentarypictures.com',
    );

Assuming that C<$mod> has not gone out of scope or been destroyed, the values
you supplied as arguments to C<new()> -- B<with two important exceptions> 
-- will be saved in a F<Personal/Defaults.pm> file stored in your home 
directory.  The next time you invoke ExtUtils::ModuleMaker, the new 
values will appear in the appropriate locations in the files created 
by C<complete_build()>.

What are those two important exceptions?

=over 4

=item * C<NAME>

You cannot enter a default value for C<NAME>:  the name of the module
you are creating.  ExtUtil::ModuleMaker's own defaults file omits a value for
C<NAME> to prevent you from overwriting an already existing module.  (More
precisely, the default value is an empty string.  ExtUtil::ModuleMaker will
throw an error if you attempt to create a module whose name is empty.)  This
precaution applies to your personal defaults file as well.

=item * C<ABSTRACT>

Since every module you create presumably has its own unique purpose, every
module must have a unique C<ABSTRACT> to summarize that purpose.
ExtUtil::ModuleMaker supplies the following string as the default value for
the C<ABSTRACT> key:

    Module abstract (<= 44 characters) goes here

... a string which, not coincidentally, happens to be exactly 44 characters
long -- so you can just overstrike it.  This will be the default value for
C<ABSTRACT> in any F<Personal/Defaults.pm> file you create as well.

=back

=head3 Methods Called Internally and How to Customize ExtUtils::ModuleMaker by Overriding Them

There are a variety of other ExtUtil::ModuleMaker methods which are not
currently in the public interface.  As they are primarily used within 
C<new()> and C<complete_build()>, their implementation and interface may 
change in the future.  See the code for inline documentation.

Most of these private methods supply the 'boilerplate' text found in the files
created by C<complete_build()>.  They are found in
F<lib/ExtUtils/ModuleMaker/StandardText.pm> and are available for you 
to hack on.

You can customize the files created by ExtUtils::ModuleMaker by overriding any
of the quasi-private methods called by
C<ExtUtils::ModuleMaker::complete_build()>.  To do so, you should first study
package ExtUtils::ModuleMaker::StandardText which is included in this
distribution.  Identify the method controlling a particular aspect of the
files built by ExtUtils::ModuleMaker.  Create a new package whose name begins
with 'ExtUtils::ModuleMaker::'.  Revise the relevant method(s) as needed and
place the revised methods in this new package.  Install this package in the
location on your system where all other locally installed Perl packages are
installed or in the same directory tree as Personal::Defaults.  Supply the
package's name as the value of the C<ALT_BUILD> argument to the constructor.

=head1 CAVEATS

=over 4

=item * Tests Require Perl 5.6

While the maintainer has attempted to make the code in
F<lib/ExtUtils/Modulemaker.pm> and the F<modulemaker> utility compatible
with versions of Perl older than 5.6, the test suite currently requires
5.6 or later.  Eventually, we'll put those tests which absolutely
require 5.6 or later into SKIP blocks so that the tests will run cleanly
on 5.4 or 5.5.

=item * Testing of F<modulemaker>'s Interactive Mode

The easiest, laziest and recommended way of using this distribution is
the command-line utility F<modulemaker>, especially its interactive
mode.  However, this is necessarily the most difficult test, as its
testing would require capturing the STDIN, STDOUT and STDERR for a
process spawned by a C<system('modulemaker')> call from within a test
file.  For now, the maintainer has relied on repeated visual inspection
of the screen prompts generated by F<modulemaker>.

=item * Testing F<modulemaker> on Non-*nix-Like Operating Systems

Since testing the F<modulemaker> utility from within the test suite
requires a C<system()> call, a clean test run depends in part on the way
a given operating system parses command-line arguments.  The maintainer
has tested this on Darwin and Win32 and, thanks to a suggestion by A.
Sinan Unur, solved a problem on Win32.  Results on other operating
systems may differ; feedback is welcome.

=back

=head1 AUTHOR/MAINTAINER

ExtUtils::ModuleMaker was originally written in 2001-02 by R. Geoffrey Avery
(modulemaker [at] PlatypiVentures [dot] com).  Since version 0.33 (July
2005) it has been maintained by James E. Keenan (jkeenan [at] cpan [dot]
org).

=head1 SUPPORT

Send email to jkeenan [at] cpan [dot] org.  Please include 'modulemaker'
in the subject line.

=head1 ACKNOWLEDGMENTS

Thanks first and foremost to Geoff Avery for creating ExtUtils::Modulemaker
and popularizing it via presentations I attended at YAPC::NA::2003 (Boca
Raton) and YAPC::EU::2003 (Paris).

Soon after I took over maintenance of ExtUtils::ModuleMaker, David A
Golden became a driving force in its ongoing development, providing
suggestions for additional functionality as well as bug reports.

Thanks for suggestions about testing the F<modulemaker> utility to 
Michael G Schwern on perl.qa and A Sinan Unur and Paul Lalli on 
comp.lang.perl.misc.  Thanks for help in dealing with a nasty bug in the 
testing to Perlmonks davidrw and tlm.  That well known Perl hacker, Anonymous 
Guest, contributed another bug report  on rt.cpan.org.

As development proceeded, several issues were clarified by members of
Perlmonks.org.  CountZero, xdg, Tanktalus, holli, TheDamian and nothingmuch
made particularly useful suggestions, as did Brian Clarkson.

Thanks also go to the following beta testers:  Alex Gill, Marc Prewitt, Scott
Godin, Reinhard Urban.

=head1 COPYRIGHT

Copyright (c) 2001-2002 R. Geoffrey Avery.
Revisions from v0.33 forward (c) 2005 James E. Keenan.  All rights reserved.
This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=head1 SEE ALSO

F<modulemaker>, F<perlnewmod>, F<h2xs>, F<ExtUtils::MakeMaker>.

=cut



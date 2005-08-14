#!/usr/local/bin/perl
use strict;
use Cwd;
use Test::More 
# qw(no_plan);
tests => 7;

SKIP: {
    eval { require 5.006_001 and require Expect::Simple };
    skip "tests require File::Temp, core with 5.6, and also Expect::Simple", 7 if $@;
    use warnings;
    use_ok( 'File::Temp', qw| tempdir |);
    my $cwd = cwd();
    my ($tdir, $topdir, @pred, $module_name, $pmfile, %pred);
    {
        # provide name and call for compact top-level directory
        # add in abstract
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');
        
        my ($obj, $cmd, $res, @lines);
        $obj = new Expect::Simple {
            Cmd => qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/modulemaker" -cn XYZ::ABC -a \"This is very abstract.\"}, #"
            Prompt => [ -re => 'Please choose which feature you would like to edit:\s+' ], 
            DisconnectCmd => 'quit',
            Verbose => 0,
            Debug => 0,
            Timeout => 100
        };
        isa_ok($obj, 'Expect::Simple');
        
        $cmd = 'G';
        $obj->send( $cmd );
        
        ($res = $obj->before) =~ tr/\r//d;
        @lines = split( "\n", $res );
# print STDERR "$lines[0]\n";        
        like($lines[3], qr/^Module files ready for generation/,
		"'Module files' line is okay");
        like($lines[10], qr/^N - Name of module\s+'XYZ::ABC'/,
		"'Name of module' line is okay");
        like($lines[11], qr/^S - Abstract\s+'This is very abstract.'/,
		"'Abstract' line is okay");
        
#        $obj->send( $obj->{DisconnectCmd} );

        ok(chdir $cwd, 'changed back to original directory after testing');
#        my $lin = 'lines';
#        open my $fh, ">$lin" or die "Couldn't open $lin for writing: $!";
#        print $fh "$_\n" for @lines;
#        close $fh or die "Couldn't close: $!";
    }
} # end SKIP block

__END__
        my $lin = 'lines';
        open my $fh, ">$lin" or die "Couldn't open $lin for writing: $!";
        print $fh "$_\n" for @lines;
        close $fh or die "Couldn't close: $!";

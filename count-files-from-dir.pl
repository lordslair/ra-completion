#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Long;
use Data::Dumper;

#
# Variables initialization
#
my %opts    = ( );

my %RESULT;
my @dirList;

my $binFind = `which find`;
chomp $binFind;

GetOptions( \%opts,
            "verbose|v",
            "help|h",
            "path|p=s",
            "min|m=s"
          );

my $min    = defined $opts{'min'} ? $opts{'min'} : '1000';

# Mini-verbose sub
sub verbose
{
    if ($opts{'verbose'})
    {   
        my $text2verb = join(' ', @_);print "[ ".$text2verb."\n";
    }
}

sub findFiles
{
    my $dir = shift;

    # We count number of files in direct dir
    if ( -d $dir)
    {  
        # Probably the fastest way I found to count files in a directory
        # HERE: http://www.perlmonks.org/?node_id=606766
        my @files  = <$dir/*>;
        my $fileCount = @files;

        verbose (" $fileCount \t: $dir");

        if ( $fileCount > $min )
        {
	    # If the number of files in the selected subpath > $opts{'min'} we
	    # store the information in %RESULT for later use
            $RESULT{$dir} = $fileCount;
        }
    }
}

# This sub creates with the command find a hierarchical array of the directories
# which are under the path given
# These subpaths are stored in @dirList
sub findDirs
{
    my $toParseDir = shift;
    # we list subdirs
    if ( -d $toParseDir)
    {  
        open (DIRLIST, "$binFind '$toParseDir' -type d 2>/dev/null | ");
            @dirList = <DIRLIST>;
        close (DIRLIST);
    }
    else
    {  
        print "ERROR: '$toParseDir' is not a directory\n";
    }
}

# --help
if ( $opts{'help'} || !$opts{'path'} )
{   
    printf STDERR ("Syntax: %s [-h|-v] --path=<PATH>\n", $0);
    printf STDERR ("  -h, --help                           this help                              |\n");
    printf STDERR ("  -v, --verbose                        increase verbosity                     |\n");
    printf STDERR ("\n");
    printf STDERR ("Options :\n");
    printf STDERR ("------------\n");
    printf STDERR ("  -m, --min   <MAX>                    we output results when count > min     | default : $min\n");
    printf STDERR ("  -p, --path  <PATH>                   path you want to analyze               | /!\\ Mandatory\n");
    exit 0;
}

if ( $opts{'path'} ) { verbose ("We received --path = $opts{'path'}") }
if ( $opts{'min'}  ) { verbose ("We received --min  = $opts{'min'}") }

findDirs($opts{'path'});

foreach my $dir (@dirList)
{
    chomp ($dir);
    # For each subpaths stored in @dirList we will count how many files
    findFiles($dir);
}

# We parse %RESULT with a numeric sort, and print it
foreach my $dir ( sort { $RESULT{$b} <=> $RESULT{$a} } keys %RESULT )
{ 
    printf ("%-5d : %-100s\n", $RESULT{$dir}, $dir);
}

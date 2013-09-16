#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Long;
use Data::Dumper;

#
# Variables initialization
#
my %opts    = ( );
my %Games;

my @files;

GetOptions( \%opts,
            "verbose|v",
            "help|h",
            "path|p=s",
            "dest|d=s",
          );

# Mini-verbose sub
sub verbose
{
    if ($opts{'verbose'})
    {   
        my $text2verb = join(' ', @_);print "[ ".$text2verb."\n";
    }
}

# --help
if ( $opts{'help'} || !$opts{'path'} )
{   
    printf STDERR ("Syntax: %s [-h|-v]\n", $0);
    printf STDERR ("  -h, --help                           this help                              |\n");
    printf STDERR ("  -v, --verbose                        increase verbosity                     |\n");
    printf STDERR ("\n");
    printf STDERR ("Options :\n");
    printf STDERR ("------------\n");
    printf STDERR ("  -p, --path  <PATH>                   path you want to analyze               |\n");
    printf STDERR ("  -d, --dest  <PATH>                   path where you want to put the roms    |\n");
    exit 0;
}

verbose ("We received --path = $opts{'path'}");
verbose ("We received --dest = $opts{'dest'}");

if ( ! -d $opts{'dest'} ) { print "ERROR: $opts{'dest'} is not a valid path\n";exit 1 }

# We list files in path
if ( -d $opts{'path'})
{
    @files  = <$opts{'path'}/*>;
}


foreach my $file ( @files )
{
    verbose ($file);
    $file =~ s/$opts{'path'}//;
    $file =~ s/^\///;
    if ( $file =~ /(.*) \((\w*)\) .*\[(\w*|[!])\][.]\w*$/ )
    {
        # Air Diver (U) [!].bin
        verbose ("name    : $1");
        verbose ("country : $2");
        verbose ("code    : $3");
        $Games{$1}{$2}{$3} = "$opts{'path'}/$file";
    }
    elsif ( $file =~ /(.*) \((\w*)\)[.]\w*$/ )
    {
        # Air Diver (J).bin
        verbose ("name    : $1");
        verbose ("country : $2");
        $Games{$1}{$2}{'RAW'} = "$opts{'path'}/$file";
    }
}

foreach my $game ( sort keys %Games )
{
    my $found = 0;
    foreach my $zone ( sort keys %{$Games{$game}} )
    {
        my @codes = ( sort keys %{$Games{$game}{$zone}} );
        if ( grep { /(^!$)|(^RAW$)|(^M$)/ } @codes )
        {
            verbose ("FOUND: $game valid  GOOD DUMP for $zone");
            $found++;
        }
    }
    if ( $found == 0 )
    {
        print "SHIT!: $game has no GOOD DUMP\n";
    }
    else
    {
        if    ( $Games{$game}{'E'}{'!'}     ) { `cp -a "$Games{$game}{'E'}{'!'}"     $opts{'dest'}` }
        elsif ( $Games{$game}{'JUE'}{'!'}   ) { `cp -a "$Games{$game}{'JUE'}{'!'}"   $opts{'dest'}` }
        elsif ( $Games{$game}{'UJE'}{'!'}   ) { `cp -a "$Games{$game}{'UJE'}{'!'}"   $opts{'dest'}` }
        elsif ( $Games{$game}{'UEJ'}{'!'}   ) { `cp -a "$Games{$game}{'UEJ'}{'!'}"   $opts{'dest'}` }
        elsif ( $Games{$game}{'JE'}{'!'}    ) { `cp -a "$Games{$game}{'JE'}{'!'}"    $opts{'dest'}` }
        elsif ( $Games{$game}{'UE'}{'!'}    ) { `cp -a "$Games{$game}{'UE'}{'!'}"    $opts{'dest'}` }
        elsif ( $Games{$game}{'W'}{'!'}    ) { `cp -a "$Games{$game}{'W'}{'!'}"    $opts{'dest'}` }
        elsif ( $Games{$game}{'U'}{'!'}     ) { `cp -a "$Games{$game}{'U'}{'!'}"     $opts{'dest'}` }
        elsif ( $Games{$game}{'UJ'}{'!'}     ) { `cp -a "$Games{$game}{'UJ'}{'!'}"     $opts{'dest'}` }
        elsif ( $Games{$game}{'JU'}{'!'}     ) { `cp -a "$Games{$game}{'JU'}{'!'}"     $opts{'dest'}` }
        elsif ( $Games{$game}{'J'}{'!'}     ) { `cp -a "$Games{$game}{'J'}{'!'}"     $opts{'dest'}` }

        elsif ( $Games{$game}{'E'}{'RAW'}   ) { `cp -a "$Games{$game}{'E'}{'RAW'}"   $opts{'dest'}` }
        elsif ( $Games{$game}{'JUE'}{'RAW'} ) { `cp -a "$Games{$game}{'JUE'}{'RAW'}" $opts{'dest'}` }
        elsif ( $Games{$game}{'UJE'}{'RAW'} ) { `cp -a "$Games{$game}{'UJE'}{'RAW'}" $opts{'dest'}` }
        elsif ( $Games{$game}{'UEJ'}{'RAW'} ) { `cp -a "$Games{$game}{'UEJ'}{'RAW'}" $opts{'dest'}` }
        elsif ( $Games{$game}{'JE'}{'RAW'}  ) { `cp -a "$Games{$game}{'JE'}{'RAW'}"  $opts{'dest'}` }
        elsif ( $Games{$game}{'UE'}{'RAW'}  ) { `cp -a "$Games{$game}{'UE'}{'RAW'}"  $opts{'dest'}` }
        elsif ( $Games{$game}{'W'}{'RAW'}  ) { `cp -a "$Games{$game}{'W'}{'RAW'}"  $opts{'dest'}` }
        elsif ( $Games{$game}{'U'}{'RAW'}   ) { `cp -a "$Games{$game}{'U'}{'RAW'}"   $opts{'dest'}` }
        elsif ( $Games{$game}{'UJ'}{'RAW'}   ) { `cp -a "$Games{$game}{'UJ'}{'RAW'}"   $opts{'dest'}` }
        elsif ( $Games{$game}{'JU'}{'RAW'}   ) { `cp -a "$Games{$game}{'JU'}{'RAW'}"   $opts{'dest'}` }
        elsif ( $Games{$game}{'J'}{'RAW'}   ) { `cp -a "$Games{$game}{'J'}{'RAW'}"   $opts{'dest'}` }
        
        elsif ( $Games{$game}{'W'}{'M'}     ) { `cp -a "$Games{$game}{'W'}{'M'}"     $opts{'dest'}` }
        elsif ( $Games{$game}{'J'}{'M'}     ) { `cp -a "$Games{$game}{'J'}{'M'}"     $opts{'dest'}` }

    }
}

#!/usr/bin/perl
use strict;
use warnings;

use lib '/code/lib';
use RAB::RAAPI;

my $rafile  = '/code/ra-config.yaml';
my $user_ra = $ARGV[0];

my $rank = RAB::RAAPI::GetUserRankAndScore($rafile,$user_ra);
print $rank, "\n";

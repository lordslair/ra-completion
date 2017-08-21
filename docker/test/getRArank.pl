#!/usr/bin/perl
use strict;
use warnings;

use lib '/home/ra_bot/lib';
use RAB::RAAPI;

my $rafile  = '/home/ra_bot/ra-config.yaml';
my $user_ra = $ARGV[0];

my $rank = RAB::RAAPI::GetUserRankAndScore($rafile,$user_ra);
print $rank, "\n";

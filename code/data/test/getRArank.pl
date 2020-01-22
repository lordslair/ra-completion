#!/usr/bin/perl
use strict;
use warnings;

use lib '/code/lib';
use RAB::RAAPI;

print RAB::RAAPI::GetUserRankAndScore($ARGV[0]), "\n";

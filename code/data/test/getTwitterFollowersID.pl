#!/usr/bin/perl
use strict;
use warnings;

use lib '/code/lib';
use RAB::Twitter;

foreach my $id (@{RAB::Twitter::getFollowersID()}) { print $id."\n" }

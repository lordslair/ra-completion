#!/usr/bin/perl
use strict;
use warnings;

use lib '/code/lib';
use RAB::Twitter;

foreach my $name (@{RAB::Twitter::getFollowers()}) { print $name."\n" }

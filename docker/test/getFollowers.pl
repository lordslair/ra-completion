#!/usr/bin/perl

use strict;
use warnings;

use lib '/home/ra_bot/lib';
use RAB::Twitter;

#
# Variables initialization
#

my $followers_ref = RAB::Twitter::getFollowers;

foreach my $name (@{$followers_ref})
{
    print "$name\n";
}

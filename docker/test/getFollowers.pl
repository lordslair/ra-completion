#!/usr/bin/perl

use strict;
use warnings;

use lib '/home/ra_bot/lib';
use RAB::Twitter;

binmode(STDOUT, ":utf8");

#
# Variables initialization
#

my $followers_id_ref = RAB::Twitter::getFollowersID;

foreach my $id (@{$followers_id_ref})
{
    print "$id\n";
}

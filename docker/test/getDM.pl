#!/usr/bin/perl
use strict;
use warnings;

use lib '/home/ra_bot/lib';
use RAB::Twitter;

my $DM = RAB::Twitter::Statuses;
foreach my $user ( sort keys %{$DM} )
{
    print $user, "\n";
}

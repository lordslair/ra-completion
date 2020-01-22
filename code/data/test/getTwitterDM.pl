#!/usr/bin/perl
use strict;
use warnings;

use lib '/code/lib';
use RAB::Twitter;

my $DM_ref = RAB::Twitter::Statuses;
my %DM     = %{$DM_ref};

print "Twitter User         | DM id                | DM content                                         | DM Creation date\n";
print "====================   ====================   ==================================================   ==============================\n";

foreach my $user ( sort keys %DM )
{
    foreach my $id ( reverse sort keys %{$DM{$user}{'dm'}} )
    {
        printf "%-20s | %20d | %-50s | %30s\n", $user, $id, $DM{$user}{'dm'}{$id}{'text'}, $DM{$user}{'dm'}{$id}{'created_at'};
        last;
    }
}

#!/usr/bin/perl
use strict;
use warnings;

use lib '/code/lib';
use RAB::Twitter;

binmode(STDOUT, ":utf8");

#
# Variables initialization
#

my $Mentions = RAB::Twitter::getMentions;

foreach my $id ( sort keys %{$Mentions} )
{
    my $okko;
    my $username =  RAB::Twitter::SenderName($Mentions->{$id}{'sender_id'});

    if ( $Mentions->{$id}{'replied'} ) { $okko = 'X' } else { $okko = ' ' }
    printf "[%1s] | %-20d | %-15s | %-20s | %-15s | %.60s\n", $okko, $id, $Mentions->{$id}{'sender'}, $Mentions->{$id}{'sender_id'}, $username, $Mentions->{$id}{'text'};
}

#!/usr/bin/perl
use strict;
use warnings;

use Net::Twitter::Lite::WithAPIv1_1;

use lib '/code/lib';

#
# Variables initialization
#

my $twitter = Net::Twitter::Lite::WithAPIv1_1->new(
    access_token_secret => $ENV{'TWITTTS'},
    consumer_secret     => $ENV{'TWITTST'},
    access_token        => $ENV{'TWITTAT'},
    consumer_key        => $ENV{'TWITTCK'},
    user_agent          => 'RA Completion Bot',
    ssl => 1,
);

my $rates_ref = $twitter->rate_limit_status('statuses');
my %Rates     = %{$rates_ref};

for my $rate ( keys %{$Rates{'resources'}{'statuses'}} )
{
    printf "%-30s | %3d/%3d\n", $rate, $Rates{'resources'}{'statuses'}{$rate}{'remaining'}, $Rates{'resources'}{'statuses'}{$rate}{'limit'};
}

#!/usr/bin/perl

use strict;
use warnings;

use Net::Twitter::Lite::WithAPIv1_1;

use lib '/home/untappd-map/lib';
use YAML::Tiny;

#
# Variables initialization
#

my $twitterfile = '/home/ra_bot/twitter-config.yaml';
my $twittyaml = YAML::Tiny->read( $twitterfile );
my $twitter = Net::Twitter::Lite::WithAPIv1_1->new(
    access_token_secret => $twittyaml->[0]{AccessTokenSecret},
    consumer_secret     => $twittyaml->[0]{ConsumerSecret},
    access_token        => $twittyaml->[0]{AccessToken},
    consumer_key        => $twittyaml->[0]{ConsumerKey},
    user_agent          => 'RA Completion Bot',
    ssl => 1,
);

my $rates_ref = $twitter->rate_limit_status('statuses');
my %Rates     = %{$rates_ref};

for my $rate ( keys %{$Rates{'resources'}{'statuses'}} )
{
    printf "%-30s | %3d/%3d\n", $rate, $Rates{'resources'}{'statuses'}{$rate}{'remaining'}, $Rates{'resources'}{'statuses'}{$rate}{'limit'};
}

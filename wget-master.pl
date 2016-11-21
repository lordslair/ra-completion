#!/usr/bin/perl
use strict;
use warnings;

use LWP::Simple qw(getstore);
use LWP::UserAgent;

my $url      = 'https://github.com/lordslair/ra_bot/archive/master.zip';
my $filename = 'master.zip';
my $save     = "/tmp/$filename";

my $ua = LWP::UserAgent->new();
my $response = $ua->get($url);
die $response->status_line if !$response->is_success;
my $file = $response->decoded_content( charset => 'none' );

getstore($url,$save);

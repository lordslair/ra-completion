#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

use lib '/code/lib';
use RAB::SQL;


binmode(STDOUT, ":utf8");

#
# Variables initialization
#

my %Mentions = RAB::SQL::getMentions();

foreach my $id ( sort keys %Mentions )
{
  my $okko;
  if ( $Mentions{$id}{'replied'} ) { $okko = 'X' } else { $okko = ' ' }

  printf "[%1s] | %-20d | @%-15s | %10s | %.60s\n", $okko,
                                                    $Mentions{$id}{'twitt_id'},
                                                    $Mentions{$id}{'sender_screen_name'},
                                                    $Mentions{$id}{'created_at'},
                                                    $Mentions{$id}{'twitt_text'};
}

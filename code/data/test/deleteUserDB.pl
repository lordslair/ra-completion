#!/usr/bin/perl

use strict;
use warnings;

use DBI;

use lib '/code/lib';
use RAB::SQLite;

my $user     = $ARGV[0];

RAB::SQLite::DeleteUser($user);
system ("/home/ra_bot/test/getDatabase.pl");

#!/usr/bin/perl
use strict;
use warnings;

use DBI;

use lib '/code/lib';
use RAB::SQLite;

my $codedir       = '/code';
my $testdir       = $codedir . '/data/test';

my $user     = $ARGV[0];

system ("$testdir/getDatabase.pl");
RAB::SQLite::DeleteUser($user);
system ("$testdir/getDatabase.pl");

#!/usr/bin/perl
use strict;
use warnings;

use DBI;

use lib '/code/lib';
use RAB::SQLite;

my $codedir       = '/code';
my $testdir       = $codedir . '/data/test';

my $user     = $ARGV[0];
my $id       = $ARGV[1];
my $mode     = $ARGV[2];

system ("$testdir/getDatabase.pl");
RAB::SQLite::SetGameAsDone($user,$id,$mode);
system ("$testdir/getDatabase.pl");

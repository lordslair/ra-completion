#!/usr/bin/perl
use strict;
use warnings;

use DBI;

use lib '/code/lib';
use RAB::SQL;

my $codedir       = '/code';
my $testdir       = $codedir . '/data/test';

my $user     = $ARGV[0];

system ("$testdir/getDatabase.pl");
RAB::SQL::DeleteUser($user);
system ("$testdir/getDatabase.pl");

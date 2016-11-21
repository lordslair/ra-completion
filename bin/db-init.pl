#!/usr/bin/perl
use strict;
use warnings;

use DBI;

my $dbh = DBI->connect(
    "dbi:SQLite:dbname=ra_completion.db",
    "",
    "",
    { RaiseError => 1 },
) or die $DBI::errstr;

$dbh->do("CREATE TABLE Users(Id INT PRIMARY KEY, user_twitter TEXT, user_ra TEXT, ack TEXT, help TEXT, done_normal TEXT, done_hardcore TEXT)")

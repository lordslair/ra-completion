#!/usr/bin/perl
use strict;
use warnings;

use DBI;

my $basedir = '/db';
my $db      = 'ra-completion.db';

if ( ! -f "$basedir/$db" || -z "$basedir/$db" )
{
    print STDERR "$basedir/$db\n";
    my $dbh = DBI->connect(
        "dbi:SQLite:dbname=$basedir/$db",
        "",
        "",
        { RaiseError => 1 },
    ) or die $DBI::errstr;

    $dbh->do("CREATE TABLE Users(Id INT PRIMARY KEY, user_twitter TEXT, user_ra TEXT, ack TEXT, help TEXT, done_normal TEXT, done_hardcore TEXT)")
}
else
{
    print STDERR "DB already exists, doin' nothin'\n";
}

#!/usr/bin/perl
use strict;
use warnings;

use DBI;

my $driver   = 'SQLite';
my $basedir  = '/code/db';
my $db       = 'ra-completion.db';
my $dsn      = "DBI:$driver:dbname=$basedir/$db";

if ( ! -f "$basedir/$db" || -z "$basedir/$db" )
{
    my $dbh = DBI->connect($dsn, '', '', { RaiseError => 1 }) or die $DBI::errstr;
    $dbh->do("CREATE TABLE Users(Id INT PRIMARY KEY, user_twitter TEXT, user_ra TEXT, ack TEXT, help TEXT, done_normal TEXT, done_hardcore TEXT)")
}
else
{
    print STDERR "DB already exists, doin' nothin'\n";
}

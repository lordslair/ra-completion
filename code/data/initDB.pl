#!/usr/bin/perl
use strict;
use warnings;

use DBI;

my $driver     = 'mysql';
my $SQL_DBNAME = $ENV{'SQL_DBNAME'};
my $SQL_DBHOST = $ENV{'SQL_DBHOST'};
my $SQL_DBUSER = $ENV{'SQL_DBUSER'};
my $SQL_DBPASS = $ENV{'SQL_DBPASS'};
my $SQL_DBPORT = $ENV{'SQL_DBPORT'};
my $dsn        = "DBI:$driver:database=$SQL_DBNAME;host=$SQL_DBHOST;port=$SQL_DBPORT";

my $dbh = DBI->connect($dsn, $SQL_DBUSER, $SQL_DBPASS, { RaiseError => 1 }) or die $DBI::errstr;
   $dbh->do("CREATE TABLE IF NOT EXISTS Users(Id INT PRIMARY KEY, user_twitter TEXT, user_ra TEXT, ack TEXT, help TEXT, done_normal TEXT, done_hardcore TEXT)");

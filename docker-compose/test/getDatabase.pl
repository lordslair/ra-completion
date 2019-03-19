#!/usr/bin/perl

use DBI;
use strict;

my $driver   = "SQLite";
my $database = "/home/ra_bot/ra_completion.db";
my $dsn      = "DBI:$driver:dbname=$database";
my $userid   = "";
my $password = "";

my $dbh = DBI->connect($dsn, $userid, $password, { RaiseError => 1 })
   or die $DBI::errstr;

my $stmt = qq(SELECT Id, user_twitter, user_ra, ack, help, done_normal, done_hardcore  from Users;);
my $sth  = $dbh->prepare( $stmt );
my $rv   = $sth->execute() or die $DBI::errstr;

if($rv < 0) {  print $DBI::errstr }

print "Id        |    Twitter User |         RA User |  ACK | HELP | Normal               | Harcore\n";
print "=========   ===============   ===============   ====   ====   ====================   ====================\n";

while (my @row = $sth->fetchrow_array())
{
    printf "%5d | %15s | %15s | %4s | %4s | %20s | %20s\n", $row[0], $row[1], $row[2], $row[3], $row[4], $row[5], $row[6];
}
$dbh->disconnect();

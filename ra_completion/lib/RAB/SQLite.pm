package RAB::SQLite;

use DBI;

my $dbh = DBI->connect(
    "dbi:SQLite:dbname=/root/git/foobar/ra_completion/ra_completion.db",
    "",
    "",
    { RaiseError => 1 },
) or die $DBI::errstr;

sub GetTwitterUsers
{
    my $sth = $dbh->prepare( "SELECT user_twitter FROM Users;" );
    $sth->execute();
    my @twitter_users = $sth->fetchrow();
    $sth->finish();

    return @twitter_users;
}

sub CreateTwitterUser
{   
    my $id   = shift;
    my $user = shift;
    my $help = shift;
    my $sth  = $dbh->prepare( "INSERT INTO Users VALUES('$id','$user','','','$help');");
    $sth->execute();
    $sth->finish();
}

sub GetAck
{
    my $user = shift;
    my $sth = $dbh->prepare( "SELECT ack FROM Users WHERE user_twitter='$user';");
       $sth->execute();
    my $ack = $sth->fetchrow();
       $sth->finish();

    return $ack;
}

sub SetAck
{
    my $user = shift;
    $dbh->do("UPDATE Users SET help='DONE' WHERE user_twitter='$user'");
}

sub GetHelp
{
    my $user = shift;
    my $sth = $dbh->prepare( "SELECT help FROM Users WHERE user_twitter='$user';");
       $sth->execute();
    my $help = $sth->fetchrow();
       $sth->finish();

    return $help;
}

sub AddRAUser
{
    my $user    = shift;
    my $user_ra = shift;

    $dbh->do("UPDATE Users SET user_ra='$user_ra' WHERE user_twitter='$user'");
    $dbh->do("UPDATE Users SET ack='yes'          WHERE user_twitter='$user'");
}

sub DeleteUser
{
    my $user    = shift;
    $dbh->do("DELETE FROM Users WHERE user_twitter='$user'");
}

sub GetTwitterUserIfExist
{
    my $user = shift;
    my $sth  = $dbh->prepare( "SELECT user_twitter FROM Users WHERE user_twitter='$user';");
       $sth->execute();
    my $ret  = $sth->fetchrow();
       $sth->finish();

    return $ret;
}

sub GetRegisteredUsers
{
    $sth = $dbh->prepare( "SELECT user_twitter,user_ra FROM Users WHERE ack='yes';");
    $sth->execute();

    return $sth->fetchrow_hashref();
}

1;

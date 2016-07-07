package RAB::SQLite;

use DBI;

my $dbh = DBI->connect(
    "dbi:SQLite:dbname=/root/git/foobar/ra_completion/ra_completion.db",
    "",
    "",
    { RaiseError => 1 },
) or die $DBI::errstr;

#$dbh->do("CREATE TABLE Users(Id INT PRIMARY KEY, user_twitter TEXT, user_ra TEXT, ack TEXT, help TEXT, done_normal TEXT, done_hardcore TEXT)");

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
    my $sth  = $dbh->prepare( "INSERT INTO Users VALUES('$id','$user','','','$help','','');");
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
    $sth = $dbh->prepare( "SELECT Id,user_twitter,user_ra FROM Users WHERE ack='yes';");
    $sth->execute();

    while(my $row = $sth->fetchrow_hashref())
    {
        $USERS{$row->{Id}}{'user_twitter'} = $row->{user_twitter};
        $USERS{$row->{Id}}{'user_ra'}      = $row->{user_ra};
    }
    return \%USERS;
}

sub SetGameAsDone
{
    my $user = shift;
    my $id   = shift;
    my $mode = shift;

    if ( $mode eq 'normal' or $mode eq 'hardcore' )
    {
        my $sth = $dbh->prepare( "SELECT done_$mode FROM Users WHERE user_twitter='$user';");
           $sth->execute();
        my $done  = $sth->fetchrow();
           $sth->finish();

        my @done_games = split /,/, $done;

        if (my ($matched) = grep $_ eq $id, @done_games)
        {
            # No action if game is already into done games
            return 'already_in_db';
        }
        else
        {
            if ( $done eq '' )
            {
                $dbh->do("UPDATE Users SET done_$mode='$id' WHERE user_twitter='$user'");
            }
            else
            {
                $done .= ",$id";
                $dbh->do("UPDATE Users SET done_$mode='$done' WHERE user_twitter='$user'");
            }
            return 'added_in_db';
        }
    }
}

1;

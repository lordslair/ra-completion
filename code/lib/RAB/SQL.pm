package RAB::SQL;

use DBI;

my $driver     = 'mysql';
my $SQL_DBNAME = $ENV{'SQL_DBNAME'};
my $SQL_DBHOST = $ENV{'SQL_DBHOST'};
my $SQL_DBUSER = $ENV{'SQL_DBUSER'};
my $SQL_DBPASS = $ENV{'SQL_DBPASS'};
my $SQL_DBPORT = $ENV{'SQL_DBPORT'};
my $dsn        = "DBI:$driver:database=$SQL_DBNAME;host=$SQL_DBHOST;port=$SQL_DBPORT";

my $dbh = DBI->connect($dsn, $SQL_DBUSER, $SQL_DBPASS, { RaiseError => 1 })
  or die $DBI::errstr;

sub GetTwitterUsers
{
    my $sth = $dbh->prepare( "SELECT user_twitter FROM Users;" );
    $sth->execute();
    my @twitter_users;
    while (my $lastline = $sth->fetchrow_array)
    {
        push @twitter_users, $lastline;
    }
    $sth->finish();

    return @twitter_users;
}

sub CreateTwitterUser
{
    my $id   = shift;
    my $user = shift;
    my $help = shift;
    my $sth  = $dbh->prepare( "INSERT INTO Users  (sender_id,user_twitter,ack,help)
                                           VALUES (?,?,?,?);");
    $sth->execute($id,$user,'no',$help);
    $sth->finish();
}

sub StoreTwitt
{
    my $twitt_id           = shift;
    my $sender_id          = shift;
    my $sender_name        = shift;
    my $sender_screen_name = shift;
    my $twitt_text         = shift;
    my $created_at         = shift;

    if (! GetTwittFromId($twitt_id))
    {
        my $sth  = $dbh->prepare( "INSERT INTO Twitts (twitt_id,sender_id,sender_name,sender_screen_name,twitt_text,created_at)
                                               VALUES (?,?,?,?,?,?);");
        $sth->execute($twitt_id,$sender_id,$sender_name,$sender_screen_name,$twitt_text,$created_at);
        $sth->finish();
    }
}

sub getMentions
{
  my $hash;
  eval
  {
      $hash = $dbh->selectall_hashref("SELECT * FROM Twitts;", 'Id' );
  } or do {
      my $error = $@ || 'Unknown failure';
      chomp ($error);
      print "[SYSTEM] SQL QUERY FAIL: $error";
      next;
  };
  return %$hash;
}

sub GetTwittFromId
{
    my $twitt_id = shift;
    my $sth = $dbh->prepare( "SELECT * FROM Twitts WHERE twitt_id='$twitt_id';");
       $sth->execute();
    my $twitt = $sth->fetchrow();
       $sth->finish();

    return $twitt;
}

sub StoreTwittReplied
{
    my $twitt_id           = shift;
    my $sth  = $dbh->prepare( "UPDATE Twitts SET replied=True WHERE twitt_id='$twitt_id';");
    $sth->execute();
    $sth->finish();
}

sub GetLastTweetId
{
    my $sth = $dbh->prepare( "SELECT twitt_id FROM Twitts ORDER BY Id DESC LIMIT 1" );
    $sth->execute();
    my $last_tweet_id = $sth->fetchrow();
    $sth->finish();

    return $last_tweet_id;
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
    my $ack  = shift;
    $dbh->do("UPDATE Users SET ack='$ack' WHERE user_twitter='$user'");
}

sub SetHelp
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

sub CheckGameIsDone
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
    }
}

sub SetGameAsUndone
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
            # Game $id is into @done_games
            $done =~ s/,$id//;

            $dbh->do("UPDATE Users SET done_$mode='$done' WHERE user_twitter='$user'");

            return 'removed_from_db';
        }
        else
        {
            # Game $id is not into @done_games
            return 'not_in_db';
        }
    }
}

1;

#!/usr/bin/perl
use strict;
use warnings;

use Data::Dumper;
use Getopt::Long;
use Term::ANSIColor;

use lib './lib';
use YAML::Tiny;
use JSON;
use RAB::Sprites;
use RAB::RAAPI;
use RAB::Twitter;
use RAB::SQLite;

binmode(STDOUT, ":utf8");

#
# Variables initialization
#
my %opts;
my $twitterfile;
my $rafile;

GetOptions( \%opts,
            "verbose|v",
            "config-twitter=s",
            "config-ra=s",
            "help|h",
          );

my $daemonName    = "ra_bot";
my $logging       = 1;                                     # 1= logging is on
my $logFilePath   = "/home/ra_bot/log/";                   # log file path
my $logFile       = $logFilePath . $daemonName . ".log";

# turn on logging
if ($logging) {
    open LOG, ">>$logFile";
    select((select(LOG), $|=1)[0]); # make the log file "hot" - turn off buffering
}

logEntry("Starting daemon");

# --help
if ( $opts{'help'} )
{
    printf STDERR ("Syntax: %s [-h|-v]\n", $0);
    printf STDERR ("  -h, --help                           this help                              |\n");
    printf STDERR ("  -v, --verbose                        increase verbosity                     |\n");
    printf STDERR ("\n");
    printf STDERR ("Options :\n");
    printf STDERR ("------------\n");
    printf STDERR ("  -T, --config-twitter <PATH>          config file to use                     | default: ./twitter-config.yaml\n");
    printf STDERR ("  -R, --config-ra      <PATH>          config file to use                     | default: ./ra-config.yaml\n");
    exit 0;
}

if ( $opts{'config-twitter'} ) { $twitterfile = $opts{'config-twitter'} } else { $twitterfile = './twitter-config.yaml' }
if ( $opts{'config-ra'}      ) { $rafile = $opts{'config-ra'}           } else { $rafile = './ra-config.yaml'           }

if ( -f "$twitterfile" )
{
    logEntry("We got the YAMLfile : $twitterfile");
}
else
{
    printf STDERR ("Config file $twitterfile does not exist\n");
    exit 2;
}

if ( -f "$rafile" )
{
    logEntry("We got the YAMLfile : $rafile");
}
else
{
    printf STDERR ("Config file $rafile does not exist\n");
    exit 2;
}

my @twitter_users = RAB::SQLite::GetTwitterUsers;

logEntry( colored("-> RAB::Twitter::Statuses", 'cyan') );
my $DM = RAB::Twitter::Statuses;
foreach my $user ( sort keys %{$DM} )
{
    logEntry("User $user");

    my $id = (reverse sort keys %{$DM->{$user}->{'dm'}})[0];
    logEntry("\tDM($id): $DM->{$user}->{'dm'}->{$id}->{'text'}");

    if ( $DM->{$user}->{'dm'}->{$id}->{'text'} =~ /^REGISTER\s?(\w*)/ )
    {   

        if (! grep( /^$user$/, @twitter_users ))
        {   
            logEntry( "REGISTER $user");
            RAB::SQLite::CreateTwitterUser($DM->{$user}->{'id'},$user,'');
            logEntry("\tAdded in DB ($DM->{$user}->{'id'},$user)");
        }
        else
        {   
            logEntry("\tAlready in DB ($DM->{$user}->{'id'},$user)");
        }

        my $ack = RAB::SQLite::GetAck($user);

        if ( $ack ne 'yes' )
        {   
            my $user_ra = $1;
            logEntry( colored("\t-> RAB::RAAPI::GetUserRankAndScore($rafile,$user_ra)", 'cyan') );
            my $return = RAB::RAAPI::GetUserRankAndScore($rafile,$user_ra);

            if ($return)
            {   
                if ( $return eq '{"Score":0,"Rank":"1"}' )
                {   
                    logEntry("\tNot registered on RA, or shit happened");

                    if ( $ack eq 'fail' )
                    {
                         logEntry("\tAlready sent fail registration DM. I did nothing.");
                    }
                    else
                    {   
                        my $tweet = "I couldn't find your username '$user_ra' on RA.org. Check it out, and come back to me.";
                        logEntry( colored("\t-> RAB::Twitter::SendDM($user, $tweet)", 'cyan') );
                        RAB::Twitter::SendDM($user, $tweet);
                        logEntry( colored("\t-> RAB::SQLite::SetAck($user, 'fail')", 'cyan') );
                        RAB::SQLite::SetAck($user, 'fail');
                    }
                }
                else
                {
                    logEntry("\tRegistered on RA ($user), sending ACK");
                    RAB::Twitter::SendDM($user, "You're now registered\nI've associated \@$user and RetroAchievement account $user_ra");

                    logEntry( colored("\t-> RAB::SQLite::AddRAUser($user,$user_ra)", 'cyan') );
                    RAB::SQLite::AddRAUser($user,$user_ra);
                }
            }
            else
            {
                print "Erreur: No answer from RA API\n";
            }
        }
        else
        {
            logEntry("\tAlready got acknowledged (\$ack = $ack), so no DM sent");
        }
    }
    elsif ($DM->{$user}->{'dm'}->{$id}->{'text'} =~ /^DELETE/ )
    {
        logEntry("\tDelete requested");
        my $ret = RAB::SQLite::GetTwitterUserIfExist($user);

        if ( ($ret) && ($ret eq $user) )
        {
            logEntry( colored("\t->RAB::SQLite::DeleteUser($user)", 'cyan') );
            RAB::SQLite::DeleteUser($user);
            logEntry( "DELETE $user");
            RAB::Twitter::SendDM($user, "Request acknowledged.\nYou're cleaned from our databases now.");
        }
        else
        {
            logEntry("\tUser $user does not exists in DB. I did nothing.");
        }
    }
    elsif (( $DM->{$user}->{'dm'}->{$id}->{'text'} =~ /^HELP/ ) || ( $DM->{$user}->{'dm'}->{$id}->{'text'} !~ /(^HELP)|(^DELETE)|(^REGISTER\s?(\w*))/ ))
    {
        logEntry("\tHelp requested, we got '$DM->{$user}->{'dm'}->{$id}->{'text'}'");
        my $db_help = RAB::SQLite::GetHelp($user);

        if ( ! $db_help or $db_help ne 'DONE' )
        {
            logEntry("\tSending HELP to new user");
            my $message  = "Welcome to the HELP engine.\n\n";
               $message .= "Available DM requests:\n";
               $message .= "REGISTER <username> (ex REGISTER lordslair)\n";
               $message .= "DELETE (Clean from database)\n\n";
               $message .= "<username> should be your retroachievment.org username\n\n";
               $message .= "This message will be sent only once.";
            RAB::Twitter::SendDM($user, $message);
            RAB::SQLite::SetHelp($user);
        }
        else
        {
            logEntry("\tHelp already send. I did nothing.");
        }
    }
}

logEntry("We're done with twitter requests");

# Now we're looping only on followers and registered users
# To fetch data from RA on them

my $USERS = RAB::SQLite::GetRegisteredUsers;

foreach my $user_id ( keys %{$USERS} )
{
    my $user    = $USERS->{$user_id}{'user_twitter'};
    my $user_ra = $USERS->{$user_id}{'user_ra'};
    logEntry( "Looping on \@$user:$user_ra games Achievements" );

    logEntry( colored("\t-> RAB::RAAPI::GetUserRecentlyPlayedGames($rafile,$user_ra)", 'cyan') );
    my $return = RAB::RAAPI::GetUserRecentlyPlayedGames($rafile,$user_ra);

    if ($return)
    {
        logEntry("\tList of recent achievements received");
        my $JSON = decode_json($return);
        my %X;
        my @csv;

        my $max = scalar @{$JSON}; # Because I'm not sure I'll receive 10 last played games
        for (my $i = 0; $i < $max; $i++) # And we loop
        {
            push @csv, $JSON->[$i]->{GameID};
            $X{$JSON->[$i]->{GameID}} = $i;
        }

        logEntry( colored("\t-> RAB::RAAPI::GetUserProgress($rafile,$user_ra,@csv)", 'cyan') );
        my $retprogress = RAB::RAAPI::GetUserProgress($rafile,$user_ra,\@csv);
        logEntry("\tWe're done with retroachievement.org API requests");

        foreach my $id ( keys %{$retprogress} )
        {
            my $kudos;
            my $kudos_end;
            my $goodtogo;
            my $achieved;
            my $possible = $JSON->[$X{$id}]->{NumPossibleAchievements};
            my $score;
            my $mode;
            my $gamePercent;

            if ( $retprogress->{$id}->{ScoreAchievedHardcore} > 0 )
            {
                logEntry( colored("\t++ $id:$JSON->[$X{$id}]->{Title} [HARDCORE]", 'red') );
                if ( $retprogress->{$id}->{NumAchievedHardcore} == $retprogress->{$id}->{NumPossibleAchievements} )
                {
                    logEntry( colored("\t\t-> RAB::SQLite::SetGameAsDone($user,$JSON->[$X{$id}]->{GameID},'hardcore')", 'cyan') );
                    my $done = RAB::SQLite::SetGameAsDone($user,$JSON->[$X{$id}]->{GameID},'hardcore');

                    if ( $done eq 'already_in_db')
                    {
                        logEntry( "\t\t\tAlready in DB, doing nothing." );
                    }
                    else
                    {
                        logEntry( "STORE $user:$JSON->[$X{$id}]->{GameID}:HARDCORE");

                        $achieved    = $retprogress->{$id}->{NumAchievedHardcore};
                        $score       = $retprogress->{$id}->{ScoreAchievedHardcore};
                        $mode        = 'hardcore';
                        $gamePercent = sprintf("%.0f", 100*$achieved/$possible);
                        $kudos_end   = ' in HARDCORE !';
                        $goodtogo    = 'ok';

                        logEntry( "\t\t\tMarked this game ($id:$JSON->[$X{$id}]->{Title}:$mode) as DONE in DB");
                    }
                }
            }
            if ( $retprogress->{$id}->{ScoreAchieved} > 0 )
            {
                logEntry( colored("\t== $id:$JSON->[$X{$id}]->{Title}", 'green') );
                if ( $retprogress->{$id}->{NumAchievedHardcore} < $retprogress->{$id}->{NumPossibleAchievements} )
                {
                    if ( $JSON->[$X{$id}]->{NumAchieved} == $JSON->[$X{$id}]->{NumPossibleAchievements} )
                    {
                        logEntry( colored("\t\t-> RAB::SQLite::SetGameAsDone($user,$JSON->[$X{$id}]->{GameID},'normal')", 'cyan') );
                        my $done = RAB::SQLite::SetGameAsDone($user,$JSON->[$X{$id}]->{GameID},'normal');

                        if ( $done eq 'already_in_db')
                        {
                            logEntry( "\t\t\tAlready in DB, doing nothing." );
                        }
                        else
                        {
                            logEntry( "STORE $user:$JSON->[$X{$id}]->{GameID}");

                            $achieved    = $retprogress->{$id}->{NumAchieved};
                            $score       = $retprogress->{$id}->{ScoreAchieved};
                            $mode        = 'normal';
                            $gamePercent = sprintf("%.0f", 100*$achieved/$possible);
                            $kudos_end   = ' !';
                            $goodtogo    = 'ok';

                            logEntry( "\t\t\tMarked this game ($id:$JSON->[$X{$id}]->{Title}:$mode) as DONE in DB");
                        }
                    }
                    else
                    {
                        logEntry( "\t\tGame in progress but not completed ($JSON->[$X{$id}]->{NumAchieved}/$JSON->[$X{$id}]->{NumPossibleAchievements})\t=> No tweet" );
                    }
                }
                else
                {
                    logEntry( "\t\tGame already completed in hardcore ($retprogress->{$id}->{NumAchievedHardcore}/$retprogress->{$id}->{NumPossibleAchievements})\t=> No tweet" );
                }
            }

            if ( $goodtogo and $goodtogo eq 'ok' )
            {
                logEntry( colored("\t\t-> RAB::Sprites::fetch($JSON->[$X{$id}]->{ImageIcon})", 'cyan') );
                RAB::Sprites::fetch($JSON->[$X{$id}]->{ImageIcon});
                logEntry( colored("\t\t-> RAB::Sprites::create($user, $JSON->[$X{$id}]->{GameID}, $JSON->[$X{$id}]->{ImageIcon}, $gamePercent, $mode, $score, $possible)", 'cyan') );
                RAB::Sprites::create($user, $JSON->[$X{$id}]->{GameID}, $JSON->[$X{$id}]->{ImageIcon}, $gamePercent, $mode, $score, $possible);

                logEntry( "\t\tSending tweet about this");
                $kudos  = "\@$user Kudos, ";
                $kudos .= "with $achieved/$possible Achievements unlocked, ";
                $kudos .= "you completed $JSON->[$X{$id}]->{Title} ($JSON->[$X{$id}]->{ConsoleName})[$JSON->[$X{$id}]->{GameID}]";
                $kudos .= $kudos_end;

                logEntry( colored("\t\t-> RAB::Twitter::FormatTweet($kudos)", 'cyan') );
                my $tweet = RAB::Twitter::FormatTweet($kudos);

                logEntry( colored("\t\t-> RAB::Twitter::SendTweetMedia(\"$tweet\",\"img/$user/$JSON->[$X{$id}]->{GameID}.png\")", 'cyan') );
                logEntry( "TWEET $user:$JSON->[$X{$id}]->{GameID}");
                RAB::Twitter::SendTweetMedia($tweet,"img/$user/$JSON->[$X{$id}]->{GameID}.png");
            }
        }
    }
}

# add a line to the log file
sub logEntry {
    my ($logText) = @_;
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime(time);
    my $dateTime = sprintf "%4d-%02d-%02d %02d:%02d:%02d |", $year + 1900, $mon + 1, $mday, $hour, $min, $sec;
    if ($logging) {
        print LOG "$dateTime $logText\n";
    }
}

# do this stuff when exit() is called.
END {
    if ($logging)
    {
        logEntry("Stopping daemon");
        close LOG;
    }
}

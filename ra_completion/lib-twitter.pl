#!/usr/bin/perl
use strict;
use warnings;

use Data::Dumper;
use Getopt::Long;

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
my $logfile = './lib-twitter.log';
my $twitterfile;
my $rafile;

GetOptions( \%opts,
            "verbose|v",
            "config-twitter=s",
            "config-ra=s",
            "help|h",
          );

# Mini-verbose sub
sub verbose
{   
    if ($opts{'verbose'})
    {   
        my $text2verb = join(' ', @_);print "[ ".$text2verb."\n";
    }
}

# Mini-log sub
sub plog
{
    my $msg       = shift;
    my @lt        = localtime;
    my $msgprefix = '|';
    # Format current datetime sensibly:
    my $dt = sprintf("%d-%02d-%02d %02d:%02d:%02d",
                     $lt[5]+1900,$lt[4]+1,
                     $lt[3],$lt[2],$lt[1],$lt[0]);

    unless (open(F,">>$logfile"))
    {
        warn "$dt $0: sub plog: Failed to open logfile ($logfile) for write.\n";
    }
    else
    {
        if ( $msg )
        {
            print F "$dt $msgprefix $msg\n";
        }
        else
        {
            warn "$dt $0: sub plog: No message!\n";
        }
        close F;
    }
}

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
    verbose ("We got the YAMLfile : $twitterfile");
}
else
{
    printf STDERR ("Config file $twitterfile does not exist\n");
    exit 2;
}

if ( -f "$rafile" )
{   
    verbose ("We got the YAMLfile : $rafile");
}
else
{   
    printf STDERR ("Config file $rafile does not exist\n");
    exit 2;
}

my @twitter_users = RAB::SQLite::GetTwitterUsers;

verbose ("-> RAB::Twitter::Statuses");
my $DM = RAB::Twitter::Statuses;
foreach my $user ( sort keys %{$DM} )
{
    verbose ("User $user");

    my $id = (reverse sort keys %{$DM->{$user}->{'dm'}})[0];
    verbose ("\tDM($id): $DM->{$user}->{'dm'}->{$id}->{'text'}");

    if ( $DM->{$user}->{'dm'}->{$id}->{'text'} =~ /^REGISTER\s?(\w*)/ )
    {

        if (! grep( /^$user$/, @twitter_users ))
        {
            plog ( "REGISTER $user");
            RAB::SQLite::CreateTwitterUser($DM->{$user}->{'id'},$user,'');
            verbose ("\tAdded in DB ($DM->{$user}->{'id'},$user)");
        }
        else
        {
            verbose ("\tAlready in DB ($DM->{$user}->{'id'},$user)");
        }

        my $ack = RAB::SQLite::GetAck($user);

        if ( $ack ne 'yes' )
        {
            my $user_ra = $1;
            verbose ("\t-> RAB::RAAPI::GetUserRankAndScore($rafile,$user_ra)");
            my $return = RAB::RAAPI::GetUserRankAndScore($rafile,$user_ra);

            if ($return)
            {
                if ( $return eq '{"Score":0,"Rank":"1"}' )
                {
                    verbose ("\tNot registered on RA, or shit happened");
                    RAB::Twitter::SendDM($user, "I couldn't find your username '$user_ra' on RA.org\nCheck it out, and come back to me.");
                }
                else
                { 
                    verbose ("\tRegistered on RA ($user), sending ACK");
                    RAB::Twitter::SendDM($user, "You're now registered\nI've associated \@$user and RetroAchievement account $user_ra");

                    verbose ("\t-> RAB::SQLite::AddRAUser($user,$user_ra)");
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
            verbose ("\tAlready got acknowledged (\$ack = $ack), so no DM sent");
        }
    }
    elsif ($DM->{$user}->{'dm'}->{$id}->{'text'} =~ /^DELETE/ )
    {
        verbose ("\tDelete requested");
        my $ret = RAB::SQLite::GetTwitterUserIfExist($user);

        if ( ($ret) && ($ret eq $user) )
        {   
            verbose ("\t->RAB::SQLite::DeleteUser($user)");
            RAB::SQLite::DeleteUser($user);
            plog ( "DELETE $user");
            RAB::Twitter::SendDM($user, "Request acknowledged.\nYou're cleaned from our databases now.");
        }
        else
        {
            verbose ("\tUser $user does not exists in DB. I did nothing.");
        }
    }
    elsif (( $DM->{$user}->{'dm'}->{$id}->{'text'} =~ /^HELP/ ) || ( $DM->{$user}->{'dm'}->{$id}->{'text'} !~ /(^HELP)|(^DELETE)|(^REGISTER\s?(\w*))/ ))
    {
        verbose ("\tHelp requested, we got '$DM->{$user}->{'dm'}->{$id}->{'text'}'");
        my $db_help = RAB::SQLite::GetHelp($user);

        if ( ! $db_help )
        {
            verbose ("\tSending HELP to new user");
            RAB::Twitter::SendDM($user, "Welcome to the HELP engine.\nAvailable DM requests:\n\nREGISTER <username> (ex REGISTER lordslair)\nDELETE (Clean from database)\n\nThis message will be sent only once.");
            RAB::SQLite::CreateTwitterUser($DM->{$user}->{'id'},$user,'DONE');
        }   
        elsif ( $db_help ne 'DONE' )
        {
            verbose ("\tSending HELP");
            RAB::Twitter::SendDM($user, "Welcome to the HELP engine.\nAvailable DM requests:\n\nREGISTER <username> (ex REGISTER lordslair)\nDELETE (Clean from database)\n\nThis message will be sent only once.");
            RAB::SQLite::SetAck($user);
        }   
        else
        {
            verbose ("\tHelp already send. I did nothing.");
        }   
    }

}

verbose ("We're done with twitter requests");

# Now we're looping only on followers and registered users
# To fetch data from RA on them

my $USERS = RAB::SQLite::GetRegisteredUsers;

foreach my $user_id ( keys %{$USERS} )
{
    verbose ("\t-> RAB::RAAPI::GetUserRecentlyPlayedGames($rafile,$USERS->{$user_id}{'user_ra'})");
    my $return = RAB::RAAPI::GetUserRecentlyPlayedGames($rafile,$USERS->{$user_id}{'user_ra'});

    if ($return)
    {
        verbose ("\tList of recent achievements received");
        my $JSON = decode_json($return);
        my %X;
        my @csv;

        my $max = scalar @{$JSON}; # Because I'm not sure I'll receive 10 last played games
        for (my $i = 0; $i < $max; $i++) # And we loop
        {
            push @csv, $JSON->[$i]->{GameID};
            $X{$JSON->[$i]->{GameID}} = $i;
        }       

        verbose ("\t-> RAB::RAAPI::GetUserProgress($rafile,$USERS->{$user_id}{'user_ra'},@csv)");
        my $retprogress = RAB::RAAPI::GetUserProgress($rafile,$USERS->{$user_id}{'user_ra'},\@csv);

        foreach my $id ( keys %{$retprogress} )
        {
            if ( $retprogress->{$id}->{ScoreAchievedHardcore} > 0 )
            {   
                if ( $retprogress->{$id}->{NumAchievedHardcore} < $retprogress->{$id}->{NumPossibleAchievements} )
                {
                }
            }
            elsif ( $retprogress->{$id}->{ScoreAchieved} > 0 )
            {   
                if ( $retprogress->{$id}->{NumAchievedHardcore} < $retprogress->{$id}->{NumPossibleAchievements} )
                {   
                    verbose ( "\t\tMarking this game ($id:$JSON->[$X{$id}]->{Title}) as DONE in DB");
                    verbose ( "\t\t-> RAB::SQLite::SetGameAsDone($USERS->{$user_id}{'user_twitter'},$JSON->[$X{$id}]->{GameID},'normal')" );
                    my $done = RAB::SQLite::SetGameAsDone($USERS->{$user_id}{'user_twitter'},$JSON->[$X{$id}]->{GameID},'normal');

                    if ( $done eq 'already_in_db')
                    {   
                        verbose ( "\t\t\tAlready in DB, doing nothing." );
                    }
                    else
                    {
                        plog ( "STORE $USERS->{$user_id}{'user_twitter'}:$JSON->[$X{$id}]->{GameID}");

                        my $gamePercent = sprintf("%.0f", 100*$JSON->[$X{$id}]->{NumAchieved}/$JSON->[$X{$id}]->{NumPossibleAchievements});
                        verbose ( "\t\t-> RAB::Sprites::fetch($JSON->[$X{$id}]->{ImageIcon})");
                        RAB::Sprites::fetch($JSON->[$X{$id}]->{ImageIcon});
                        verbose ( "\t\t-> RAB::Sprites::create($JSON->[$X{$id}]->{GameID}, $JSON->[$X{$id}]->{ImageIcon}, $gamePercent, 'normal', $JSON->[$X{$id}]->{ScoreAchieved}, $JSON->[$X{$id}]->{NumPossibleAchievements})");
                        RAB::Sprites::create($JSON->[$X{$id}]->{GameID}, $JSON->[$X{$id}]->{ImageIcon}, $gamePercent, 'normal', $JSON->[$X{$id}]->{ScoreAchieved}, $JSON->[$X{$id}]->{NumPossibleAchievements});

                        if ( $JSON->[$X{$id}]->{NumAchieved} == $JSON->[$X{$id}]->{NumPossibleAchievements} )
                        {
                            verbose ( "\t\tSending tweet about this");
                            my $kudos  = "\@$USERS->{$user_id}{'user_twitter'} Kudos, ";
                               $kudos .= "with $JSON->[$X{$id}]->{NumAchieved}/$JSON->[$X{$id}]->{NumPossibleAchievements} Achievements unlocked, ";
                               $kudos .= "you completed $JSON->[$X{$id}]->{Title} ($JSON->[$X{$id}]->{ConsoleName})[$JSON->[$X{$id}]->{GameID}] !";

                            verbose ( "\t\t\t-> RAB::Twitter::FormatTweet($kudos)" );
                            my $tweet = RAB::Twitter::FormatTweet($kudos);

                            verbose ( "\t\t\t-> RAB::Twitter::SendTweetMedia(\"$tweet","/var/www/html/$JSON->[$X{$id}]->{GameID}.png\")" );
                            plog ( "TWEET $USERS->{$user_id}{'user_twitter'}:$JSON->[$X{$id}]->{GameID}");
                            RAB::Twitter::SendTweetMedia($tweet,"/var/www/html/$JSON->[$X{$id}]->{GameID}.png");
                        }
                        else
                        {
                            verbose ( "\t\t\tGame not completed ($JSON->[$X{$id}]->{NumAchieved}/$JSON->[$X{$id}]->{NumPossibleAchievements}) => No tweet about it" );
                        }
                    }
                }
                else
                {   
                    verbose ( "\t\t$retprogress->{$id}->{NumAchieved}/$retprogress->{$id}->{NumPossibleAchievements} for game $JSON->[$id]->{GameID} ($JSON->[$id]->{ImageIcon}) = Not enough progress" );
                }
            }
        }
    }
}

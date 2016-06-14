#!/usr/bin/perl
use strict;
use warnings;

use Term::ANSIColor;
use Data::Dumper;
use Getopt::Long;
use Net::Twitter::Lite::WithAPIv1_1;
use YAML::Tiny;
use LWP;

binmode(STDOUT, ":utf8");

#
# Variables initialization
#
my %opts;
my %DM;
my %RA;
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

my $twittyaml = YAML::Tiny->read( $twitterfile );
print Dumper $twittyaml;

my $rayaml = YAML::Tiny->read( $rafile );
print Dumper $rayaml;

my $twitter = Net::Twitter::Lite::WithAPIv1_1->new(
    access_token_secret => $twittyaml->[0]{AccessTokenSecret},
    consumer_secret     => $twittyaml->[0]{ConsumerSecret},
    access_token        => $twittyaml->[0]{AccessToken},
    consumer_key        => $twittyaml->[0]{ConsumerKey},
    user_agent          => 'RA Completion Bot',
    ssl => 1,
);

my $lastmsg = $twitter->direct_messages({ count => 1 });
my $lasmsg_id = ${$lastmsg}[0]->{id};

while ( )
{

    my $statuses = $twitter->direct_messages({ max_id => $lasmsg_id, count => 20 });
    for my $status ( @$statuses )
    {

        $DM{$status->{sender}{screen_name}}{'dm'}{$status->{id}}{'created_at'} = $status->{created_at};
        $DM{$status->{sender}{screen_name}}{'dm'}{$status->{id}}{'text'}       = $status->{text};

        $lasmsg_id = $status->{id} - 1;
    }
    if ( scalar(@$statuses) != 20 ) { last }
}

verbose ("No more Twitter API accesses beyond this point");

foreach my $user ( sort keys %DM )
{
    foreach my $id ( sort keys %{$DM{$user}{'dm'}} )
    {
        if ( $DM{$user}{'dm'}{$id}{'text'} =~ /^ra\s?:\s?(\w*)/ )
        {
            $RA{$user}{'login'} = $1;

            my $browser = new LWP::UserAgent;
            my $request = new HTTP::Request( GET => "http://retroachievements.org/API/API_GetUserRankAndScore.php?z=$rayaml->[0]{ra_user}&y=$rayaml->[0]{ra_api_key}&u=$RA{$user}{'login'}" );
            my $headers = $request->headers();
               $headers->header( 'User-Agent','Mozilla/5.0 (compatible; Konqueror/3.4; Linux) KHTML/3.4.2 (like Gecko)');
               $headers->header( 'Accept', 'text/html, image/jpeg, image/png, text/*, image/*, */*');
               $headers->header( 'Accept-Encoding','x-gzip, x-deflate, gzip, deflate');
               $headers->header( 'Accept-Charset', 'iso-8859-15, utf-8;q=0.5, *;q=0.5');
               $headers->header( 'Accept-Language', 'fr, en');
               $headers->header( 'Referer', 'http://retroachievements.org/API');
            my $response = $browser->request($request);

            if ($response->is_success)
            {
                my $headers = $response->headers();
                verbose ("User is registered on RA, sending ACK ... $user");
                my $message_ack = "You're now registered\nI've now associated \@$user and RetroAchievement account $RA{$user}{'login'}";
                my $ack     = $twitter->new_direct_message({ user => $user, text => $message_ack });
            }
            else
            {
                print "Erreur:".$response->status_line."\n";  
            }
        }
    }
}

print Dumper %RA;

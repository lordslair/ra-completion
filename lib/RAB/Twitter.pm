package RAB::Twitter;

use Net::Twitter::Lite::WithAPIv1_1;
use YAML::Tiny;

#
# Variables initialization
#
my $twitterfile = './twitter-config.yaml';
my $twittyaml = YAML::Tiny->read( $twitterfile );
my $twitter = Net::Twitter::Lite::WithAPIv1_1->new(
    access_token_secret => $twittyaml->[0]{AccessTokenSecret},
    consumer_secret     => $twittyaml->[0]{ConsumerSecret},
    access_token        => $twittyaml->[0]{AccessToken},
    consumer_key        => $twittyaml->[0]{ConsumerKey},
    user_agent          => 'RA Completion Bot',
    ssl => 1,
);

sub Statuses
{
    my $lastmsg_id  = $twitter->direct_messages({ count => 1 });
    while ( )
    {   
        my $statuses    = $twitter->direct_messages({ max_id => $lastmsg_id, count => 20 });
        for my $status ( @$statuses )
        {   
            $DM{$status->{sender}{screen_name}}{'id'}                              = $status->{sender_id};
            $DM{$status->{sender}{screen_name}}{'dm'}{$status->{id}}{'created_at'} = $status->{created_at};
            $DM{$status->{sender}{screen_name}}{'dm'}{$status->{id}}{'text'}       = $status->{text};

            $lastmsg_id = $status->{id} - 1;
        }
        if ( scalar(@$statuses) != 20 ) { last }
    }
    return \%DM;
}

sub FormatTweet
{
    my $text   = shift;
    my $tco    = 25;
    my $length = 140 - $tco;

    if ( @{[$text =~ /./sg]} < $length )
    {   
        # We're goot with text length
    }
    else
    {   
        $text  = substr( $text, 0, $length - 3 );
        $text .= '...';
    }
    return $text;
}

sub SendDM
{   
    my $user  = shift;
    my $text  = shift;

    my $dm    = $twitter->new_direct_message({ user => $user, text => $text }); 
}


sub SendTweetMedia
{
    my $text  = shift;
    my $media = shift;

    my $update = $twitter->update_with_media({ status => $text, media => [ $media ] });
}

1;

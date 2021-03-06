package RAB::Twitter;
use strict;
use warnings;

use Net::Twitter::Lite::WithAPIv1_1;

#
# Variables initialization
#

my $twitter = Net::Twitter::Lite::WithAPIv1_1->new(
    access_token_secret => $ENV{'TWITTTS'},
    consumer_secret     => $ENV{'TWITTST'},
    access_token        => $ENV{'TWITTAT'},
    consumer_key        => $ENV{'TWITTCK'},
    user_agent          => 'RA Completion Bot',
    ssl => 1,
);

sub getMentions
{
    my %Mentions;
    my $lastmsg_id  = $twitter->mentions({ count => 1 });
    while ( )
    {
        my $mentions    = $twitter->mentions({ max_id => $lastmsg_id, count => 20 });
        for my $mention ( @$mentions )
        {
            $Mentions{$mention->{id}}{'sender_id'}  = $mention->{user}{id};
            $Mentions{$mention->{id}}{'created_at'} = $mention->{created_at};
            $Mentions{$mention->{id}}{'text'}       = $mention->{text};
            $Mentions{$mention->{id}}{'sender'}     = $mention->{user}{name};

            $lastmsg_id = $mention->{id} - 1;
        }
        if ( scalar(@$mentions) != 20 ) { last }
    }

    $lastmsg_id  = $twitter->user_timeline({ count => 1 });
    while ( )
    {
        my $replies    = $twitter->user_timeline({ max_id => $lastmsg_id, count => 20 });
        for my $reply ( @$replies )
        {
            my $id = $reply->{in_reply_to_status_id};
            if ( $id )
            {
            # This tweet is already a response to someone's mention
                $Mentions{$id}{'replied'} = 'yes';
            }
            else { }
            $lastmsg_id = $reply->{id} - 1;
        }
        if ( scalar(@$replies) != 20 ) { last }
    }
    return \%Mentions;
}

sub SenderName
{
    my $id = shift;

    my $user     = $twitter->show_user({ user_id => $id });
    my $username = $user->{'screen_name'};

    return $username;
}

sub Statuses
{
    my $lastmsg_id  = $twitter->direct_messages({ count => 1 });
    my %DM;
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
    my $tco    = 15;
    my $length = 140 - $tco;

    if ( @{[$text =~ /./sg]} < $length )
    {   
        # We're good with text length
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

sub SendTweet
{
    my $id     = shift;
    my $text   = shift;

    my $update = $twitter->update({ in_reply_to_status_id => $id, status => $text });
}

sub getFollowersID
{
    my $followers_list = $twitter->followers_ids({screen_name => 'ra_completion'});

    return \@{$followers_list->{ids}}
}

sub getFollowers
{
    my $followers_list_ref = $twitter->followers_list({screen_name => 'ra_completion'});

    my %followers_list     = %{$followers_list_ref};
    my @followers_users    = $followers_list{'users'};

    my @followers_data     = @{$followers_users[0]};
    my @followers;

    foreach my $follower (@followers_data)
    {
        push @followers, $follower->{'screen_name'};
    }
    return \@followers;
}

1;

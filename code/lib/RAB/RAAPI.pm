package RAB::RAAPI;

use LWP;
use JSON;

#
# Variables initialization
#

sub GetUserRecentlyPlayedGames
{
    my $user   = shift;

    my $browser = new LWP::UserAgent;
    my $request = new HTTP::Request( GET => "http://retroachievements.org/API/API_GetUserRecentlyPlayedGames.php?z=$ENV{'RAUSER'}&y=$ENV{'RAKEY'}&u=$user&c=25" );
    my $headers = $request->headers();
       $headers->header( 'User-Agent','Mozilla/5.0 (compatible; Konqueror/3.4; Linux) KHTML/3.4.2 (like Gecko)');
       $headers->header( 'Accept', 'text/html, image/jpeg, image/png, text/*, image/*, */*');
       $headers->header( 'Accept-Charset', 'iso-8859-15, utf-8;q=0.5, *;q=0.5');
       $headers->header( 'Accept-Language', 'fr, en');
       $headers->header( 'Referer', 'http://retroachievements.org/API');
    my $response = $browser->request($request);

    if ($response->is_success)
    {
        return $response->content;
    }
}

sub GetUserRankAndScore
{
    my $user   = shift;

    my $browser = new LWP::UserAgent;
    my $request = new HTTP::Request( GET => "http://retroachievements.org/API/API_GetUserRankAndScore.php?z=$ENV{'RAUSER'}&y=$ENV{'RAKEY'}&u=$user" );
    my $headers = $request->headers();
       $headers->header( 'User-Agent','Mozilla/5.0 (compatible; Konqueror/3.4; Linux) KHTML/3.4.2 (like Gecko)');
       $headers->header( 'Accept', 'text/html, image/jpeg, image/png, text/*, image/*, */*');
       $headers->header( 'Accept-Charset', 'iso-8859-15, utf-8;q=0.5, *;q=0.5');
       $headers->header( 'Accept-Language', 'fr, en');
       $headers->header( 'Referer', 'http://retroachievements.org/API');
    my $response = $browser->request($request);

    if ($response->is_success)
    {
        return $response->content;
    }

}

sub GetUserProgress
{
    my $user   = shift;
    my $csvref = shift;
    my $csv    = join(',', @{$csvref});

    my $browser = new LWP::UserAgent;
    my $request = new HTTP::Request( GET => "http://retroachievements.org/API/API_GetUserProgress.php?z=$ENV{'RAUSER'}&y=$ENV{'RAKEY'}&u=$user&i=$csv" );
    my $headers = $request->headers();
       $headers->header( 'User-Agent','Mozilla/5.0 (compatible; Konqueror/3.4; Linux) KHTML/3.4.2 (like Gecko)');
       $headers->header( 'Accept', 'text/html, image/jpeg, image/png, text/*, image/*, */*');
       $headers->header( 'Accept-Charset', 'iso-8859-15, utf-8;q=0.5, *;q=0.5');
       $headers->header( 'Accept-Language', 'fr, en');
       $headers->header( 'Referer', 'http://retroachievements.org/API');
    my $response = $browser->request($request);

    if ($response->is_success)
    {
        return decode_json($response->content);
    }
    else
    {
        print STDERR Dumper $response;
    }
}

1;

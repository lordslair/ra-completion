package RAB::Sprites;

use Image::Magick;

#
# Variables initialization
#
my $logfile       = './lib-twitter.log';
my $tmpfolder     = '/var/www/html/tmp';
my $finalfolder   = '/var/www/html';
my $spritesfolder = './lib/RAB/Sprites';

sub fetch
{   
    my $imageIcon   = shift;
       $imageIcon   =~ s/\/Images\///;
    my $image       = "$tmpfolder/$imageIcon";

    if ( ! -f "$image" )
    {   
        `wget http://www.retroachievements.org/Images/$imageIcon -O $tmpfolder/$imageIcon`;
    }
}

sub create
{
    my $gameId      = shift;
    my $imageIcon   = shift;
       $imageIcon   =~ s/\/Images\///;
    my $imageId     = $imageIcon;
       $imageId     =~ s/.png//;
    my $gamePercent = shift;
    my $type        = shift;
    my $score       = shift;
    my $nbrachieve  = shift;
    my $image       = "$tmpfolder/$imageIcon";

        my $gameImage = Image::Magick->new;
        $gameImage->read($image);

        $gameImage->Set( Gravity => 'Center' );
        $gameImage->Resize( geometry => '64x64', background => 'transparent');
        $gameImage->Extent( geometry => '64x64', background => 'transparent');
        $gameImage->Write( "$tmpfolder/$imageId-64x64.png" );

        my $big = Image::Magick->new;
        $big->read("$spritesfolder/base.png");

        my $little = Image::Magick->new;
        $little->Read("$tmpfolder/$imageId-64x64.png");
        $big->Composite( image => $little, qw (compose SrcAtop geometry +31+64));

        my $dots = Image::Magick->new;
        $dots->Read("$spritesfolder/base-dots.png");
        $big->Composite( image => $dots, qw (compose SrcAtop geometry center));

        my $cadre = Image::Magick->new;
        $cadre->Read("$spritesfolder/base-cadre.png");
        $big->Composite( image => $cadre, qw (compose SrcAtop geometry center));

        my $bar = Image::Magick->new;
        $bar->read("$spritesfolder/base-bar.png");
        $big->Composite( image => $bar, qw (compose SrcAtop geometry center));

        if ( $gamePercent =~ /^(\d)(\d)$/ )
        {
            my $nbr1 = Image::Magick->new;
            $nbr1->Read("$spritesfolder/digit-$1X.png");

            my $nbr2 = Image::Magick->new;
            $nbr2->Read("$spritesfolder/digit-$2.png");

            $big->Composite( image => $nbr1, qw (compose SrcAtop geometry center));
            $big->Composite( image => $nbr2, qw (compose SrcAtop geometry center));
        }
        elsif ( $gamePercent =~ /^(\d)$/ )
        {
            my $nbr1 = Image::Magick->new;
            $nbr1->Read("$spritesfolder/digit-$1.png");

            $big->Composite( image => $nbr1, qw (compose SrcAtop geometry center));
        }
        elsif ( $gamePercent =~ /^(\d)(\d)(\d)$/ )
        {
            my $nbr1 = Image::Magick->new;
            $nbr1->Read("$spritesfolder/digit-$1XX.png");

            my $nbr2 = Image::Magick->new;
            $nbr2->Read("$spritesfolder/digit-$2X.png");

            my $nbr3 = Image::Magick->new;
            $nbr3->Read("$spritesfolder/digit-$3.png");

            $big->Composite( image => $nbr1, qw (compose SrcAtop geometry center));
            $big->Composite( image => $nbr2, qw (compose SrcAtop geometry center));
            $big->Composite( image => $nbr3, qw (compose SrcAtop geometry center));
        }

        # Creation of % bar
        if ( $gamePercent > 0 )
        {   
            my $pixels = sprintf("%.0f", 122/100 * $gamePercent);
            my $endpos = 122 - $pixels;
            my $end = Image::Magick->new;
            $end->Read("$spritesfolder/bar-end.png");
            $big->Composite( image    => $end,
                             compose  => 'SrcAtop',
                             geometry => "+$endpos+0" );

            my $unit = Image::Magick->new;
            $unit->Read("$spritesfolder/bar-unit.png");
            while ( $pixels >= 0 )
            {   
                $big->Composite( image    => $unit,
                                 compose  => 'SrcAtop',
                                 geometry => "-$pixels+0" );
                --$pixels
            }

            my $start = Image::Magick->new;
            $start->Read("$spritesfolder/bar-start.png");
            $big->Composite( image => $start, qw (compose SrcAtop geometry center));
        }
        my $bar = Image::Magick->new;
        $bar->read("$spritesfolder/base-bar.png");
        $big->Composite( image => $bar, qw (compose SrcAtop geometry center));

        if ( $type eq 'hardcore' )
        {
            my $hardcore = Image::Magick->new;
            $hardcore->read("$spritesfolder/bar-hardcore.png");
            $big->Composite( image => $hardcore, qw (compose SrcAtop geometry center));
        }

        my $scorebg = Image::Magick->new;
        $scorebg->read("$spritesfolder/base-score.png");
        $big->Composite( image => $scorebg, qw (compose SrcAtop geometry center));

        if ( $score =~ /^(\d)(\d)(\d)$/ )
        {   
            my $nbr1 = Image::Magick->new;
            $nbr1->Read("$spritesfolder/digit-$1.png");

            my $nbr2 = Image::Magick->new;
            $nbr2->Read("$spritesfolder/digit-$2.png");

            my $nbr3 = Image::Magick->new;
            $nbr3->Read("$spritesfolder/digit-$3.png");

            $big->Composite( image => $nbr1, qw (compose SrcAtop geometry +64-66));
            $big->Composite( image => $nbr2, qw (compose SrcAtop geometry +73-66));
            $big->Composite( image => $nbr3, qw (compose SrcAtop geometry +82-66));
        }
        if ( $score =~ /^(\d)(\d)$/ )
        {
            my $nbr1 = Image::Magick->new;
            $nbr1->Read("$spritesfolder/digit-$1.png");

            my $nbr2 = Image::Magick->new;
            $nbr2->Read("$spritesfolder/digit-$2.png");

            $big->Composite( image => $nbr1, qw (compose SrcAtop geometry +73-66));
            $big->Composite( image => $nbr2, qw (compose SrcAtop geometry +82-66));
        }
        elsif ( $score =~ /^(\d)$/ )
        {
            my $nbr1 = Image::Magick->new;
            $nbr1->Read("$spritesfolder/digit-$1.png");

            $big->Composite( image => $nbr1, qw (compose SrcAtop geometry +82-66));
        }

        if ( $nbrachieve =~ /^(\d)(\d)(\d)$/ )
        {   
            my $nbr1 = Image::Magick->new;
            $nbr1->Read("$spritesfolder/digit-$1.png");

            my $nbr2 = Image::Magick->new;
            $nbr2->Read("$spritesfolder/digit-$2.png");

            my $nbr3 = Image::Magick->new;
            $nbr3->Read("$spritesfolder/digit-$3.png");

            $big->Composite( image => $nbr1, qw (compose SrcAtop geometry +64-52));
            $big->Composite( image => $nbr2, qw (compose SrcAtop geometry +73-52));
            $big->Composite( image => $nbr3, qw (compose SrcAtop geometry +82-52));
        }
        if ( $nbrachieve =~ /^(\d)(\d)$/ )
        {   
            my $nbr1 = Image::Magick->new;
            $nbr1->Read("$spritesfolder/digit-$1.png");

            my $nbr2 = Image::Magick->new;
            $nbr2->Read("$spritesfolder/digit-$2.png");

            $big->Composite( image => $nbr1, qw (compose SrcAtop geometry +73-52));
            $big->Composite( image => $nbr2, qw (compose SrcAtop geometry +82-52));
        }
        elsif ( $nbrachieve =~ /^(\d)$/ )
        {   
            my $nbr1 = Image::Magick->new;
            $nbr1->Read("$spritesfolder/digit-$1.png");

            $big->Composite( image => $nbr1, qw (compose SrcAtop geometry +82-52));
        }

        $big->Write( "$finalfolder/$gameId.png" );
}

1;

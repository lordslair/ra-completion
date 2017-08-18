FROM debian:jessie
MAINTAINER @Lordslair

RUN apt-get update && apt-get install -y \
    libdbd-sqlite3-perl \
    libdbi-perl \
    libimage-magick-perl \
    libnet-twitter-lite-perl \
    libwww-perl \
    php5-cli \
    php5-sqlite \
    unzip \
&& rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --shell /bin/bash ra_bot

RUN cd /tmp && perl -e 'use LWP::Simple qw(getstore); use LWP::UserAgent; my $ua = LWP::UserAgent->new(); my $url = "https://github.com/lordslair/ra_bot/archive/master.zip"; $response = $ua->get($url); my $file = $response->decoded_content( charset => 'none' ); getstore($url,"/tmp/master.zip");'
RUN cd /tmp && unzip master.zip && rm master.zip

RUN mv /tmp/ra_bot-master/tmp/bashrc.root /root/.bashrc
RUN chown -R ra_bot:ra_bot /tmp/ra_bot-master
RUN mv /tmp/ra_bot-master/tmp/bashrc.user /home/ra_bot/.bashrc

RUN cp -a /tmp/ra_bot-master/* /home/ra_bot/
RUN cp    /tmp/ra_bot-master/bin/start.sh /

RUN perl /home/ra_bot/bin/wget.pl "https://bitbucket.org/phpliteadmin/public/downloads/phpLiteAdmin_v1-9-6.zip" phpLiteAdmin.zip
RUN cd /tmp && unzip phpLiteAdmin.zip && chown ra_bot:ra_bot phpliteadmin.php && cp -a phpliteadmin.php /home/ra_bot/ && rm php*
RUN perl -i -pe "s/\'admin\'/\'6azHDvR2\'/" /home/ra_bot/phpliteadmin.php

RUN su - ra_bot -c "/home/ra_bot/bin/db-init.pl"

RUN apt-get -y remove --purge unzip

COPY twitter-config.yaml /home/ra_bot/
COPY ra-config.yaml      /home/ra_bot/

ENTRYPOINT ["/start.sh"]
EXPOSE 8000

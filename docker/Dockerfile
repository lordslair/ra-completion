FROM debian:stretch-slim
MAINTAINER @Lordslair

RUN apt-get update && apt-get install -y \
    libdbd-sqlite3-perl \
    libdbi-perl \
    libimage-magick-perl \
    libnet-twitter-lite-perl \
    libwww-perl \
    libyaml-tiny-perl \
    libfile-pid-perl \
&& rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --shell /bin/bash ra_bot

COPY bashrc.root /root/.bashrc
COPY bashrc.user /home/ra_bot/.bashrc

COPY lib/  /home/ra_bot/lib/
COPY tmp/  /home/ra_bot/tmp/
COPY test/ /home/ra_bot/test/
COPY log   /home/ra_bot/log/

COPY ra_bot      /home/ra_bot/

COPY twitter-config.yaml /home/ra_bot/
COPY ra-config.yaml      /home/ra_bot/

RUN chown -R ra_bot:ra_bot /home/ra_bot

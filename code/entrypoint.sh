#!/bin/sh

echo "`date +"%F %X"` Building Perl dependencies and system set-up ..."

apk update \
    && apk add --no-cache perl perl-libwww perl-dbi perl-dbd-sqlite imagemagick6-dev perl-net-ssleay \
    && apk add --no-cache --virtual .build-deps \
                                    curl make perl-dev libc-dev gcc bash tzdata \
    && curl -L https://cpanmin.us | perl - App::cpanminus --no-wget \
    && cpanm --no-wget File::Pid \
                       Net::Twitter::Lite \
                       Net::OAuth \
    && cpanm --no-wget Image::Magick --force \
    && cp /usr/share/zoneinfo/Europe/Paris /etc/localtime \
    && apk del .build-deps \
    && rm -rf /root/.cpanm

echo "`date +"%F %X"` Build done ..."

exec /code/ra-completion

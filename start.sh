#!/bin/bash

if [ $1 == 'webserver' ]
then
HOME='/home/ra_bot'
su - ra_bot -c "/usr/bin/php -d session.save_path=$HOME/tmp -S 0.0.0.0:8000 $HOME/phpliteadmin.php > $HOME/tmp/nohup.log"
fi

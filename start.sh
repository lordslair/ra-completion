#!/bin/bash

if [ $1 == 'webserver' ]
then
su - ra_completion -c "/usr/bin/php -d session.save_path=/home/ra_completion/tmp -S 0.0.0.0:8000 /home/ra_completion/phpliteadmin.php > /home/ra_completion/tmp/nohup.log"
fi

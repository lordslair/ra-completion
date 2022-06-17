# -*- coding: utf8 -*-

import os

# MySQL variables
MYSQL_USER     = os.environ['SQL_DBUSER']
MYSQL_PASSWORD = os.environ['SQL_DBPASS']
MYSQL_DB       = os.environ['SQL_DBNAME']
MYSQL_HOST     = os.environ['SQL_DBHOST']
MYSQL_PORT     = os.environ['SQL_DBPORT']

# SQLAlchemy variables
SQL_DSN        = MYSQL_USER + ':' + MYSQL_PASSWORD + '@' + MYSQL_HOST + ':' + MYSQL_PORT + '/' + MYSQL_DB

# Authenticate to Twitter
TWITTCK = os.environ['TWITTCK']
TWITTST = os.environ['TWITTST']
TWITTAT = os.environ['TWITTAT']
TWITTTS = os.environ['TWITTTS']

if os.environ.get("CI"):
    # Here we are inside GitHub CI process
    SPRITES_PATH = 'code/sprites'
else:
    SPRITES_PATH = 'sprites'

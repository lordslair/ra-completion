# -*- coding: utf8 -*-

import json
import tweepy

from variables                     import *

def test_tweepy_connection():
    try:
        auth = tweepy.OAuth1UserHandler(TWITTCK,
                                        TWITTST,
                                        TWITTAT,
                                        TWITTTS)

        # Create API object
        api = tweepy.API(auth)
    except Exception as e:
        pass

    assert api.verify_credentials().screen_name == 'ra_completion'

def test_tweepy_limits_mentions():
    try:
        auth = tweepy.OAuth1UserHandler(TWITTCK,
                                        TWITTST,
                                        TWITTAT,
                                        TWITTTS)

        # Create API object
        api = tweepy.API(auth)
    except Exception as e:
        pass

    mentions = api.rate_limit_status()['resources']['statuses']['/statuses/mentions_timeline']
    assert mentions['remaining'] > 0

#!/usr/bin/env python3
# -*- coding: utf8 -*-

import re
import tweepy
import time

from loguru import logger

from mysql.initialize              import initialize_db
from mysql.methods                 import *
from raapi                         import *
from sprites                       import *

from variables                     import *

def check_mentions(api, since_id):
    logger.info("Retrieving mentions")
    new_since_id = since_id
    for tweet in tweepy.Cursor(api.mentions_timeline,
        since_id=since_id).items():
        new_since_id = max(tweet.id, new_since_id)

        logger.trace(f'@{tweet.user.screen_name} : {tweet.text}')

        # We check if the tweet is already an answer ar an initial mention
        if tweet.in_reply_to_status_id is None:
            logger.trace(f'This is an initial mention')
        else:
            logger.trace(f'This is a reply')
            continue

        # We check if it is a REGISTER type of message
        if tweet.text.lower().startswith('@ra_completion register'):
            logger.info(f'REGISTER message received: @{tweet.user.screen_name} : {tweet.text}')

            m = re.match(r"@ra_completion REGISTER !(?P<ra_user>\w+)", tweet.text)
            if m is not None:
                ra_user = m.group('ra_user')
                logger.debug(f"User regextraction OK ({ra_user})")
            else:
                logger.info(f"User regextraction KO - Continue")
                continue

            try:
                user = db_user_get(ra_user)
                if user:
                    logger.debug("User already existing")
                else:
                    # We check that the RA user provided exixts
                    try:
                        payload = raapi_user_get(ra_user)
                    except Exception as e:
                        logger.error(f'RA User Query KO [{e}]')
                    else:
                        if payload['ID'] is not None:
                            logger.info(f"RA User Query OK (id:{payload['ID']},name:{ra_user})")
                        else:
                            logger.info(f"RA User Query KO - Not found")
                            api.update_status(
                                status=f"@{tweet.user.screen_name} Sorry. Couldn't find your username '{user_ra}' on RA.org. Check it out, and come back to me.",
                                in_reply_to_status_id=tweet.id,
                            )
                            continue
                    # We add the user in DB
                    try:
                        user = db_user_add(tweet,ra_user)
                    except Exception as e:
                        logger.error(f'User creation KO [{e}]')
                    else:
                        logger.info("User creation OK - Created")
                        # We answer to the twitto
                        logger.info(f"Answering to @{tweet.user.screen_name}")
                        api.update_status(
                            status=f"@{tweet.user.screen_name} Kudos. You're now associated with the RetroAchievement account : {user_ra}",
                            in_reply_to_status_id=tweet.id,
                        )
            except Exception as e:
                logger.error(f'User verification/creation KO [{e}]')

            # We follow the user
            if not tweet.user.following:
                logger.info("Following the twitto")
                tweet.user.follow()
            else:
                logger.debug("Already Following the twitto")

        # We check if it is a UNREGISTER type of message
        if tweet.text.lower().startswith('@ra_completion unregister'):
            logger.debug(f'This is a UNREGISTER message - we will answer')

    return new_since_id

def check_ra_updates():
    users = db_user_get_all()
    if not users:
        logger.warning('Users list looks empty - Skipping iteration')
        return
    for user in users:
        payload = raapi_completed_games_get(user.user_ra)
        for game in payload:
            # We need only the games with 100% completion
            if game['PctWon'] == '1.0000':
                if game['HardcoreMode'] == '0':
                    hardcore  = False
                    kudos_end = ' !'
                elif game['HardcoreMode'] == '1':
                    hardcore = True
                    kudos_end = ' in HARDCORE!'
                else:
                    logger.warning(f"Unable to process (HardcoreMode:{game['HardcoreMode']}) - Skipping (game:{game})")
                    continue

                # We check if the game is already done
                if db_game_get(user,game['GameID'],hardcore):
                    logger.debug(f"[{user.user_ra}] Game already in DB : [{game['GameID']}] {game['Title']} (HC:{hardcore})")
                else:
                    logger.info(f"[{user.user_ra}] Game entry creation TODO ([{game['GameID']}] {game['Title']})")

                    # We create the Sprite image
                    # 1- We fetch the game Icon
                    try:
                        ImageIcon = raapi_game_icon_get(game)
                    except Exception as e:
                        logger.error(f'[{user.user_ra}] Game Icon fetching KO [{e}] - Continue')
                        continue
                    else:
                        if ImageIcon:
                            logger.info(f"[{user.user_ra}] Game Icon fetching OK")
                        else:
                            logger.error(f"[{user.user_ra}] Game Icon fetching KO - Continue")
                            continue
                    # 2- We fetch the game Score
                    try:
                        score = raapi_game_score_get(user.user_ra,game)
                    except Exception as e:
                        logger.error(f'[{user.user_ra}] Game Score fetching KO [{e}] - Continue')
                        continue
                    else:
                        if ImageIcon:
                            logger.info(f"[{user.user_ra}] Game Score fetching OK")
                        else:
                            logger.error(f"[{user.user_ra}] Game Score fetching KO - Continue")
                            continue
                    # 3- We build the global Sprite
                    try:
                        ImageGenerated = wand_sprite_create(game,score)
                        print(ImageGenerated)
                    except Exception as e:
                        logger.error(f'[{user.user_ra}] Game Image creation KO [{e}]')
                        continue
                    else:
                        logger.info(f"[{user.user_ra}] Game Image creation OK")

                    # We send the tweet about it
                    try:

                        kudos  = f"@{user.user_twitter} Kudos. "
                        kudos += f"with {game['NumAwarded']}/{game['MaxPossible']} Achievements unlocked, "
                        kudos += f"you completed {game['Title']} ({game['ConsoleName']})[{game['GameID']}]"
                        kudos += kudos_end
                        logger.info(f"Tweeting: {kudos}")
                        #api.update_status(
                        #    status=f"@{user.user_twitter} Kudos.{kudos} "
                        #)
                    except Exception as e:
                        logger.error(f'[{user.user_ra}] Kudos send KO (@{user.user_twitter}) [{e}]')
                        continue
                    else:
                        logger.info(f"[{user.user_ra}] Kudos send OK (@{user.user_twitter})")

                    # We add the game as done in DB
                    try:
                        db_game_add(user,game,hardcore,score)
                    except Exception as e:
                        logger.error(f'[{user.user_ra}] Game entry creation KO [{e}]')
                    else:
                        logger.info(f"[{user.user_ra}] Game entry creation OK")

def main():
    auth = tweepy.OAuthHandler(TWITTCK, TWITTST)
    auth.set_access_token(TWITTAT, TWITTTS)

    # Create API object
    api = tweepy.API(auth)

    since_id = 1
    while True:
        # We check mentions, add/del users if needed
        since_id = check_mentions(api, since_id)
        # We loop on users to query RAAPI
        check_ra_updates()
        # Job is done, now we wait
        logger.info("Waiting...")
        time.sleep(60)

if __name__ == "__main__":
    main()

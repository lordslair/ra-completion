# -*- coding: utf8 -*-

import dataclasses
import json

from loguru                     import logger

from .session                   import Session
from .models                    import Game,User

def db_user_add(tweet,user_ra):
    session = Session()

    try:
        user = User(sender_id     = tweet.user.id,
                    user_twitter  = tweet.user.screen_name,
                    user_ra       = user_ra)

        session.add(user)
        session.commit()
        session.refresh(user)
    except Exception as e:
        session.rollback()
        logger.error(f'User Query KO - Create KO [{e}]')
        return None
    else:
        logger.debug(f'User Query OK - Create OK (tweet.user.screen_name:{tweet.user.screen_name})')
        return user

def db_user_get(user_ra):
    session = Session()

    try:
        user = session.query(User)\
                      .filter(User.user_ra == user_ra)\
                      .one_or_none()
    except Exception as e:
        msg = f'User Query KO - Failed (user_ra:{user_ra}) [{e}]'
        logger.error(msg)
        return None
    else:
        if user:
            msg = f'User Query OK (user_ra:{user_ra})'
            logger.debug(msg)
            return user
        else:
            message = f'User Query KO - Not Found (user_ra:{user_ra})'
            logger.trace(message)
            return False
    finally:
        session.close()

def db_user_get_all():
    session = Session()

    try:
        user = session.query(User)\
                      .all()
    except Exception as e:
        msg = f'Users Query KO - Failed [{e}]'
        logger.error(msg)
        return None
    else:
        if user:
            msg = f'Users Query OK'
            logger.debug(msg)
            return user
        else:
            message = f'Users Query KO - Not Found'
            logger.trace(message)
            return False
    finally:
        session.close()

def db_game_add(user,game,hardcore,score):
    session = Session()

    try:
        # We need to add the game in DB for the user
        game = Game(game_id       = game['GameID'],
                    user_twitter  = user.user_twitter,
                    user_ra       = user.user_ra,
                    hardcore      = hardcore,
                    game_title    = game['Title'],
                    game_console  = game['ConsoleName'],
                    game_raw      = json.dumps(game),
                    score_raw     = json.dumps(score))

        session.add(game)
        session.commit()
        session.refresh(game)
    except Exception as e:
        session.rollback()
        logger.error(f'Game Query KO - Failed [{e}]')
        return None
    else:
        if game:
            logger.trace(f'Game Query OK - Added')
            return game
        else:
            logger.trace(f'Game Query KO - Not Added')
            return None
    finally:
        session.close()

def db_game_get(user,game_id,hardcore):
    session = Session()

    try:
        game = session.query(Game)\
                      .filter(Game.game_id  == game_id)\
                      .filter(Game.user_ra  == user.user_ra)\
                      .filter(Game.hardcore == hardcore)\
                      .one_or_none()
    except Exception as e:
        session.rollback()
        logger.error(f'Game Query KO - Failed [{e}]')
        return None
    else:
        if game:
            logger.trace(f'Game Query OK - Found')
            return game
        else:
            logger.trace(f'Game Query KO - Not Found')
            return None
    finally:
        session.close()

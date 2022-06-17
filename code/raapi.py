# -*- coding: utf8 -*-

import json
import os
import requests

from PIL                        import Image
from io                         import BytesIO
from loguru                     import logger

from variables                  import SPRITES_PATH

API_URL  = 'https://retroachievements.org'
API_USER = os.environ['RAUSER']
API_KEY  = os.environ['RAKEY']

def raapi_user_get(ra_user):
    url      = f'{API_URL}/API/API_GetUserSummary.php?z={API_USER}&y={API_KEY}&u={ra_user}'

    try:
        response = requests.get(url,
                                timeout=(1, 1))

        if response.status_code == 200:
            if response.text:
                logger.trace(f'Request Query OK response:{json.loads(response.text)}')
                return json.loads(response.text)
        else:
            logger.warning(f'Request Query KO response:{json.loads(response.text)}')
            return None
    except Exception as e:
        logger.error(f'Request Query KO [{e}]')
        return None

def raapi_completed_games_get(ra_user):
    url      = f'{API_URL}/API/API_GetUserCompletedGames.php?z={API_USER}&y={API_KEY}&u={ra_user}'

    try:
        response = requests.get(url,
                                timeout=(1, 1))

        if response.status_code == 200:
            if response.text:
                logger.trace(f'Request Query OK response:{json.loads(response.text)}')
                return json.loads(response.text)
        else:
            logger.warning(f'Request Query KO response:{json.loads(response.text)}')
            return None
    except Exception as e:
        logger.error(f'Request Query KO [{e}]')
        return None

def raapi_game_score_get(ra_user,game):
    url      = f"{API_URL}/API/API_GetUserProgress.php?z={API_USER}&y={API_KEY}&u={ra_user}&i={game['GameID']}"

    try:
        response = requests.get(url,
                                timeout=(1, 1))

        if response.status_code == 200:
            if response.text:
                logger.trace(f'Request Query OK response:{json.loads(response.text)}')
                return json.loads(response.text)
        else:
            logger.warning(f'Request Query KO response:{json.loads(response.text)}')
            return None
    except Exception as e:
        logger.error(f'Request Query KO [{e}]')
        return None

def raapi_game_icon_get(game):
    ImageIconPath = f'{SPRITES_PATH}/icon'
    ImageIcon     = game['ImageIcon'].split('/')[2]
    url           = f'{API_URL}/Images/{ImageIcon}'

    try:
        response = requests.get(url,
                                timeout=(1, 1))

        if response.status_code == 200:
            if response.content:
                logger.trace(f'Request Query OK')
                i = Image.open(BytesIO(response.content))
                i.save(f'{ImageIconPath}/{ImageIcon}')
                return ImageIcon
        else:
            logger.warning(f'Request Query KO (url:{url},status_code:{response.status_code})')
            return None
    except Exception as e:
        logger.error(f'Request Query KO [{e}]')
        return None

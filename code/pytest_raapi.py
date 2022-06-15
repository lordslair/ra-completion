# -*- coding: utf8 -*-

import os

from raapi import *

ra_user = os.environ.get("RAUSER", None)
ra_game = os.environ.get("RAGAME", '1627')

def test_raapi_user_get():
    try:
        payload = raapi_user_get(ra_user)
    except Exception as e:
        pass

    assert payload is not None
    assert payload['UserPic'] == f'/UserPic/{ra_user}.png'


def test_raapi_completed_games_get():
    try:
        payload = raapi_completed_games_get(ra_user)
    except Exception as e:
        pass

    assert payload is not None
    assert len(payload) > 0

    for game in payload:
        if game['GameID'] == ra_game:
            assert game['PctWon'] == '1.0000'

def test_raapi_game_score_get():
    try:
        payload = raapi_completed_games_get(ra_user)
        for game in payload:
            if game['GameID'] == ra_game:
                payload = raapi_game_score_get(ra_user,game)
    except Exception as e:
        pass

    assert payload[ra_game]['NumPossibleAchievements'] == "19"
    assert payload[ra_game]['NumAchieved'] == "19"
    assert payload[ra_game]['NumAchievedHardcore'] == "19"

def test_raapi_game_icon_get():
    try:
        payload = raapi_completed_games_get(ra_user)
        for game in payload:
            if game['GameID'] == ra_game:
                payload = raapi_game_icon_get(game)
    except Exception as e:
        pass

    assert payload == "011853.png"

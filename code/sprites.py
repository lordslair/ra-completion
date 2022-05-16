# -*- coding: utf8 -*-

from wand.image                 import Image
from loguru                     import logger

ImageIconPath = '/code/sprites/icon'
ImageBasePath = '/code/sprites/base'
ImageGeneratedPath = '/code/sprites/generated'

def wand_sprite_resize(game):
    ImageIcon     = game['ImageIcon'].split('/')[2]
    ImageIconID   = ImageIcon.split('.')[0]

    try:
        icon = Image(filename = f'{ImageIconPath}/{ImageIcon}')
        icon.resize(64,64)
        icon.save(filename = f'{ImageIconPath}/{ImageIconID}-64x64.png')
    except Exception as e:
        logger.error(f'ImageIcon resize KO [{e}]')
    else:
        logger.trace(f"ImageIcon resize OK")
        return ImageIconID

def wand_sprite_base(game,score):
    GameID        = game['GameID']
    ImageIcon     = game['ImageIcon'].split('/')[2]
    ImageIconID   = ImageIcon.split('.')[0]

    try:
        base_base  = Image(filename = f'{ImageBasePath}/base.png')
        base_clone = base_base.clone()

        base_dots  = Image(filename = f'{ImageBasePath}/base-dots.png')
        base_frame = Image(filename = f'{ImageBasePath}/base-cadre.png')
        base_bar   = Image(filename = f'{ImageBasePath}/base-bar.png')
        base_score = Image(filename = f'{ImageBasePath}/base-score.png')

        icon       = Image(filename = f'{ImageIconPath}/{ImageIconID}-64x64.png')

        percent_1XX = Image(filename = f'{ImageBasePath}/digit-1XX.png')
        percent_2XX = Image(filename = f'{ImageBasePath}/digit-2XX.png')
        percent_X0X = Image(filename = f'{ImageBasePath}/digit-0X.png')
        percent_XX0 = Image(filename = f'{ImageBasePath}/digit-0.png')

        bar_start    = Image(filename = f'{ImageBasePath}/bar-start.png')
        bar_end      = Image(filename = f'{ImageBasePath}/bar-end.png')
        bar_hardcore = Image(filename = f'{ImageBasePath}/bar-hardcore.png')
        bar_unit     = Image(filename = f'{ImageBasePath}/bar-unit.png')


        logger.trace("Sprite composition: Start")
        # We add the generated 64x64 icon on top of base
        base_clone.composite(icon,
                             left=31,
                             top=64,
                             operator='over',
                             arguments=None,
                             gravity=None)

        # We add the dots on top
        base_clone.composite(base_dots,
                             left=None,
                             top=None,
                             operator='over',
                             arguments=None,
                             gravity=None)

        # We add the frame on top
        base_clone.composite(base_frame,
                             left=None,
                             top=None,
                             operator='over',
                             arguments=None,
                             gravity=None)

        # We add the score text on top
        base_clone.composite(base_score,
                             left=None,
                             top=None,
                             operator='over',
                             arguments=None,
                             gravity=None)

        logger.trace("Sprite composition: Bar")
        # We add the bar
        # Here it is a bit complicated as it could be reused for not 100% games
        percentage = int(float(game['PctWon']) * 100)
        left_pos   = int(122/100 * percentage)
        endpos     = 122 - left_pos
        # Adding the end part of the bar
        base_clone.composite(bar_end,
                             left=endpos,
                             top=None,
                             operator='over',
                             arguments=None,
                             gravity=None)
        # We add the bar filling with a loop
        while left_pos >= 0:
            base_clone.composite(bar_unit,
                                 left=int(f'-{left_pos}'),
                                 top=None,
                                 operator='over',
                                 arguments=None,
                                 gravity=None)
            left_pos -= 1
        # We add the start part of the bar
        base_clone.composite(bar_start,
                             left=endpos,
                             top=None,
                             operator='over',
                             arguments=None,
                             gravity=None)
        # We add the bar on top
        base_clone.composite(base_bar,
                             left=None,
                             top=None,
                             operator='over',
                             arguments=None,
                             gravity=None)

        logger.trace("Sprite composition: Hardcore")
        # We add the '100'% on the base
        if game['HardcoreMode'] == "0":
            filename = f'{ImageGeneratedPath}/{ImageIconID}-normal.png'
            hundred  = percent_1XX
        else:
            filename = f'{ImageGeneratedPath}/{ImageIconID}-hardcore.png'
            hundred = percent_2XX
            # We add the text 'HARDCORE' on top of the bar
            base_clone.composite(bar_hardcore,
                                 left=None,
                                 top=None,
                                 operator='over',
                                 arguments=None,
                                 gravity=None)
        base_clone.composite(hundred,
                             left=None,
                             top=None,
                             operator='over',
                             arguments=None,
                             gravity=None)
        base_clone.composite(percent_X0X,
                             left=None,
                             top=None,
                             operator='over',
                             arguments=None,
                             gravity=None)
        base_clone.composite(percent_XX0,
                             left=None,
                             top=None,
                             operator='over',
                             arguments=None,
                             gravity=None)

        logger.trace(f"Sprite composition: Achievements ({game['NumAwarded']}/{score[GameID]['NumPossibleAchievements']})")
        # We add the ACHIEVEMENT NUMBER
        if len(game['NumAwarded']) == 1:
            # The number of achievements is on one digit
            digits    = [int(a) for a in game['NumAwarded']]
            image_one = Image(filename = f'{ImageBasePath}/digit-{digits[0]}.png')
            base_clone.composite(image_one,
                                 left=82,
                                 top=-52,
                                 operator='over',
                                 arguments=None,
                                 gravity=None)
        elif len(game['NumAwarded']) == 2:
            # The number of achievements is on two digits
            digits    = [int(a) for a in game['NumAwarded']]
            image_one = Image(filename = f'{ImageBasePath}/digit-{digits[0]}.png')
            image_two = Image(filename = f'{ImageBasePath}/digit-{digits[1]}.png')
            base_clone.composite(image_one,
                                 left=73,
                                 top=-52,
                                 operator='over',
                                 arguments=None,
                                 gravity=None)
            base_clone.composite(image_two,
                                 left=82,
                                 top=-52,
                                 operator='over',
                                 arguments=None,
                                 gravity=None)

        logger.trace(f"Sprite composition: Score ({score[GameID]['ScoreAchieved']}/{score[GameID]['PossibleScore']})")
        # We add the SCORE NUMBER
        if len(score[GameID]['ScoreAchieved']) == 1:
            # The score is on one digit
            digits    = [int(a) for a in score[GameID]['ScoreAchieved']]
            image_one = Image(filename = f'{ImageBasePath}/digit-{digits[0]}.png')
            base_clone.composite(image_one,
                                 left=82,
                                 top=-66,
                                 operator='over',
                                 arguments=None,
                                 gravity=None)
        elif len(score[GameID]['ScoreAchieved']) == 2:
            # The score is on two digits
            digits    = [int(a) for a in score[GameID]['ScoreAchieved']]
            image_one = Image(filename = f'{ImageBasePath}/digit-{digits[0]}.png')
            image_two = Image(filename = f'{ImageBasePath}/digit-{digits[1]}.png')

            base_clone.composite(image_one,
                                 left=73,
                                 top=-66,
                                 operator='over',
                                 arguments=None,
                                 gravity=None)
            base_clone.composite(image_two,
                                 left=82,
                                 top=-66,
                                 operator='over',
                                 arguments=None,
                                 gravity=None)
        elif len(score[GameID]['ScoreAchieved']) == 3:
            # The score is on three digits
            digits      = [int(a) for a in score[GameID]['ScoreAchieved']]
            image_one   = Image(filename = f'{ImageBasePath}/digit-{digits[0]}.png')
            image_two   = Image(filename = f'{ImageBasePath}/digit-{digits[1]}.png')
            image_three = Image(filename = f'{ImageBasePath}/digit-{digits[2]}.png')

            base_clone.composite(image_one,
                                 left=64,
                                 top=-66,
                                 operator='over',
                                 arguments=None,
                                 gravity=None)
            base_clone.composite(image_two,
                                 left=73,
                                 top=-66,
                                 operator='over',
                                 arguments=None,
                                 gravity=None)
            base_clone.composite(image_three,
                                 left=82,
                                 top=-66,
                                 operator='over',
                                 arguments=None,
                                 gravity=None)

        logger.trace("Sprite composition: Save")
        # We save the file
        base_clone.save(filename = filename)
    except Exception as e:
        logger.error(f'ImageBase create KO [{e}]')
    else:
        logger.trace(f"ImageBase create OK")
        return filename

def wand_sprite_create(game,score):
    try:
        ImageIconID = wand_sprite_resize(game)
    except Exception as e:
        pass # Execption handled in the function lower
    else:
        try:
            ImageGenerated = wand_sprite_base(game,score)
        except Exception as e:
            pass # Execption handled in the function lower
        else:
            if ImageGenerated:
                return ImageGenerated
            else:
                return None

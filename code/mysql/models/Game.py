# -*- coding: utf8 -*-

from sqlalchemy                 import Column, Integer, DateTime, Boolean, Text, BigInteger
from sqlalchemy                 import func

from dataclasses                import dataclass
from datetime                   import datetime

from ..base                     import Base

@dataclass
class Game(Base):
    __tablename__ = 'Game'

    id:            int
    game_id:       int
    user_twitter:  str
    user_ra:       str
    hardcore:      bool
    game_title:    str
    game_console:  str
    game_raw:      str
    score_raw:     str

    id            = Column(Integer, primary_key=True)
    game_id       = Column(Integer, nullable=False)
    user_twitter  = Column(Text,    nullable=False)
    user_ra       = Column(Text,    nullable=False)
    hardcore      = Column(Boolean, nullable=False)
    game_title    = Column(Text,    nullable=False)
    game_console  = Column(Text,    nullable=False)
    game_raw      = Column(Text,    nullable=False)
    score_raw     = Column(Text,    nullable=False)

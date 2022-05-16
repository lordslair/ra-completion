# -*- coding: utf8 -*-

from sqlalchemy                 import Column, Integer, DateTime, Boolean, Text, BigInteger
from sqlalchemy                 import func

from dataclasses                import dataclass
from datetime                   import datetime

from ..base                     import Base

@dataclass
class User(Base):
    __tablename__ = 'User'

    id:            int
    sender_id:     int
    user_twitter:  str
    user_ra:       str

    id            = Column(Integer,    primary_key=True)
    sender_id     = Column(BigInteger, nullable=False)
    user_twitter  = Column(Text,       nullable=False)
    user_ra       = Column(Text,       nullable=False)

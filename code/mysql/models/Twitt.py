# -*- coding: utf8 -*-

from sqlalchemy                 import Column, Integer, DateTime, Boolean, Text
from sqlalchemy                 import func

from dataclasses                import dataclass
from datetime                   import datetime

from ..base                     import Base

@dataclass
class Twitt(Base):
    __tablename__ = 'Twitt'

    id:                 int
    twitt_id:           int
    sender_id:          int
    sender_name:        str
    sender_screen_name: str
    twitt_text:         str
    replied:            bool
    created_at:         str

    id                 = Column(Integer, primary_key=True)
    twitt_id           = Column(Integer, nullable=False)
    sender_id          = Column(Integer, nullable=False)
    sender_name        = Column(Text,    nullable=False)
    sender_screen_name = Column(Text,    nullable=False)
    twitt_text         = Column(Text,    nullable=False)
    replied            = Column(Boolean, nullable=False)
    created_at         = Column(DateTime(timezone=True), nullable=False, server_default=func.now(), server_onupdate=func.now())

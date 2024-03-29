FROM alpine:3.15
MAINTAINER @Lordslair

RUN adduser -h /code -u 1000 -D -H rac

ENV PIP_NO_CACHE_DIR=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

ARG LOGURU_DATE="<green>{time:YYYY-MM-DD HH:mm:ss}</green> | "
ARG LOGURU_LEVEL="<level>level={level: <8}</level> | "
ARG LOGURU_MSG="<cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - <level>{message}</level>"
ENV LOGURU_FORMAT=$LOGURU_DATE$LOGURU_LEVEL$LOGURU_MSG
ENV LOGURU_COLORIZE='true'
ENV LOGURU_DEBUG_COLOR='<cyan><bold>'

ENV PYTHONUNBUFFERED='True'
ENV PYTHONIOENCODING='UTF-8'

COPY                 requirements.txt /requirements.txt
COPY --chown=rac:rac /code            /code

RUN apk update --no-cache \
    && apk add --no-cache imagemagick \
                          libjpeg \
                          python3 \
    && apk add --no-cache --virtual .build-deps \
                                    gcc \
                                    g++ \
                                    jpeg-dev \
                                    libc-dev \
                                    libffi-dev \
                                    python3-dev \
                                    tzdata \
                                    zlib-dev \
    && cp /usr/share/zoneinfo/Europe/Paris /etc/localtime \
    && cd /code \
    && su rac -c "python3 -m ensurepip --upgrade \
                  && /code/.local/bin/pip3 install --user -U -r /requirements.txt" \
    && apk del .build-deps \
    && rm /requirements.txt

USER rac
WORKDIR /code
ENV PATH="/code/.local/bin:${PATH}"

ENTRYPOINT ["/code/ra-completion.py"]

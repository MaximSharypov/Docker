FROM python:3.8-alpine
ENV PYTHONUNBUFFERED=1 LIBRARY_PATH=/lib:/usr/lib
RUN mkdir /app
WORKDIR /app

RUN apk add --virtual .build-deps postgresql-libs gcc musl-dev postgresql-dev build-base python-dev py-pip jpeg-dev zlib-dev binutils libc-dev 

COPY requirements.txt /app/requirements.txt

RUN python3 -m pip install -r requirements.txt --no-cache-dir

RUN find /usr/local \
        \( -type d -a -name test -o -name tests \) \
        -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
        -exec rm -rf '{}' + \
    && runDeps="$( \
        scanelf --needed --nobanner --recursive /usr/local \
                | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
                | sort -u \
                | xargs -r apk info --installed \
                | sort -u \
    )" \
    && apk add --virtual .rundeps $runDeps \
    && apk --purge del .build-deps

COPY . /app/
FROM mdillon/postgis:11
# apt packages
RUN apt-get update && apt-get install -qqy --no-install-recommends \
    git \
    python3-dev \
    python3-pip \
    python3-setuptools \
    wget \
  && apt-get clean \
  && ln -s /usr/bin/python3 python

WORKDIR /home/
RUN git clone https://github.com/OpenTransitTools/gtfsdb.git
WORKDIR /home/gtfsdb
RUN pip3 install --upgrade pip zc.buildout sqlalchemy psycopg2-binary
RUN buildout install prod postgresql
WORKDIR /home/
RUN chmod +x .

COPY ./init.sh /docker-entrypoint-initdb.d/y_init.sh

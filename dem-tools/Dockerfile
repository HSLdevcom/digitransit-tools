FROM ubuntu:18.04

ENV WORK /demtools
RUN mkdir -p ${WORK}
WORKDIR ${WORK}
COPY . ${WORK}

ENV VENV $WORK/venv

RUN pwd
RUN apt-get update && \
    apt-get install software-properties-common -y --no-install-recommends && \
    add-apt-repository ppa:ubuntugis/ppa && \
    apt-get install gdal-bin python-gdal python3-pip -y --no-install-recommends && \ 
    rm -rf /var/lib/apt/lists/* && \
    pip3 install virtualenv

RUN virtualenv -p python3 $VENV 
ENV PATH="$VENV/bin:$PATH"
RUN pip install -r requirements.txt

CMD ./entrypoint.sh
#!/bin/bash
set -e

if [ -v GTFS ]; then
  echo "Found $GTFS"
else
  echo "GTFS env variable not found."
  exit 0
fi

cd ~
wget $GTFS
GTFS_FILENAME=${GTFS##*/}

/home/gtfsdb/bin/gtfsdb-load \
  --database_url postgresql://postgres:postges@${POSTGRES_PORT_5432_TCP_ADDR}:5432/postgres \
  --is_geospatial \
  $GTFS_FILENAME

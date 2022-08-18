#!/usr/bin/env bash

GREEN="\e[32m"
RED="\e[31m"
ENDCOLOR="\e[0m"

green () {
    echo -e "$GREEN$1$ENDCOLOR"
}

errline () {
    >&2 echo -e "$RED$1$ENDCOLOR"
}


# This script downloads GTFS file from digitransit.routing data
usage () {
    >&2 echo
    >&2 echo "Usage:"
    >&2 echo
    >&2 echo "    $0 ROUTER [VERSION] [prod]"
    >&2 echo
    >&2 echo "ROUTER:"
    >&2 echo "    hsl"
    >&2 echo
    >&2 echo "VERSION:"
    >&2 echo "    1 or 2 (default)"
    >&2 echo
}

errmsg () {
    >&2 echo
    errline "$1"
    >&2 echo
    exit 1
}

if [ -z "$1" ]
then
    usage
    errmsg "Missing argument: router"
fi

# parse dev/prod
API_STAGE="$3"
HOST_API=dev-api
if [ "$API_STAGE" = "prod" ]
then
    HOST_API=api
fi

# parse version (otp1/otp2)
VERSION=${2:-2}
if [ "$VERSION" = "1" ]
then
    ROUTER_VERSION=v2
fi

if [ "$VERSION" = "2" ]
then
    ROUTER_VERSION=v3
fi

if [ -z "$ROUTER_VERSION" ]
then
    usage
    errmsg "Invalid ROUTER VERSION"
fi

if [ "$1" = "hsl" ]; then
    ROUTER=hsl
    GTFS_FILE=HSL-gtfs.zip
fi

if [ -z $ROUTER ]; then
    errmsg "Router not supported: $1"
fi

# ensure download dir
mkdir -p gtfs

# download routing gtfs
URL="https://$HOST_API.digitransit.fi/routing-data/$ROUTER_VERSION/$ROUTER/$GTFS_FILE"
OUT_FILE="./gtfs/$ROUTER-$ROUTER_VERSION-${API_STAGE}-gtfs.zip"
echo "Start download $URL"
echo

if ! curl -o "$OUT_FILE" "$URL"; then
    errmsg "Error with curl download."
    exit 1
fi

echo
green "Download success: $OUT_FILE"
echo

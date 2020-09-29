#!/usr/bin/env bash

set -e

# Config

REPOSITORIES=("hsldevcom/opentripplanner")


# Deletion rules:
# 1) Tags in IGNORED_TAGS_ARR are not touched

# These tags or tags starting with these strings will be ignored!
IGNORED_TAGS_ARR=("latest" "prod")


# Script starts


# Helper variables
NOW_YEAR=$(date +"%y")
NOW_MONTH=$(date +"%-m") # without zero!
NOW_TIME=$(date +"%s")
# OLDER_THAN=$(expr $THRESHOLD_DAYS \* 24 \* 60 \* 60)
JSON_HEADER="Content-Type: application/json"

# Helper for logging into Docker Hub
login_data() {
cat <<EOF
{
  "username": "$DOCKER_USER",
  "password": "$DOCKER_AUTH"
}
EOF
}

# Does list contain an item, e.g. contains list item
# TODO: SKip tags starting with....
function contains() {
  local n=$#
  local value=${!n}
  for ((i=1;i < $#;i++)) {
      if [[ ${!i} =~ $value.* ]]; then
          echo "y"
          return 0
      fi
  }
  echo "n"
  return 1
}

# Loop though repositories
for NAME in "${REPOSITORIES[@]}"
do
  # (Re-)Login for each repository
  # TOKEN=`curl -s -H "$JSON_HEADER" -X POST -d "$(login_data)" "https://hub.docker.com/v2/users/login/" | jq -r .token`
  AUTH_HEADER="Authorization: JWT ${TOKEN}"
  echo "Cleaning repository: ${NAME}"

  # Get tags for a repository (paginated)
  NEXT_URL="https://hub.docker.com/v2/repositories/${NAME}/tags/" 

  # Repeat through the repository
  while [ "$NEXT_URL" != "null" ]
  do

    # Get tags for a repository (paginated)
    JSON_RESPONSE=`curl -s "$NEXT_URL" -X GET -H "$AUTH_HEADER" -H "$JSON_HEADER"`
    # Extract next url
    NEXT_URL=$(jq -r .next <<< "$JSON_RESPONSE")

    # Loop through the results from current page
    jq -c '.results[]' <<< "$JSON_RESPONSE" | while read result;
    do
      DELETE=false
      TAG=$(jq -r .name <<< "$result")
      
      # Do not process this TAG if found in the array
      if [ $(contains "${IGNORED_TAGS_ARR[@]}" "$TAG") == "y" ]; then
        echo "Skipping: ${TAG}"
      else
        echo "Checking: ${TAG}"
        #
        TAG_UPDATED=$(jq -r .last_updated <<< "$result")
        TAG_EPOCH=$(date -d "${TAG_UPDATED}" +"%s")
        TAG_YEAR=$(date -d "${TAG_UPDATED}" +"%y")
        TAG_MONTH=$(date -d "${TAG_UPDATED}" +"%-m")
        TAG_DAY=$(date -d "${TAG_UPDATED}" +"%-d")       

        if [ "$DELETE" == true ]; then
          echo "Deleting: ${TAG_NAME}"
          # TODO: ENABLE DELETION
          ## curl "https://hub.d_remove_this_docker.com/v2/repositories/${NAME}/tags/${TAG}/" -X DELETE -H "$AUTH_HEADER"
        fi

      fi
      sleep 1
    done

    sleep 1
    exit 0

  done
done


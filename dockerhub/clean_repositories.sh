#!/usr/bin/env bash

set -e

# Target repositories: repository is <org>/<image>
REPOSITORIES=("hsldevcom/opentripplanner")



# These tags or tags starting with these strings will be skipped!
SKIP_TAGS=("latest" "prod")

# Deletion rules:
# 1) Tags in SKIP_TAGS are skipped
# 2) More than one year old images will be deleted, unless they are the first tag of that year
# 3) More than one month old images will be deleted, unless they are the first tag of that month and less than year old


# Helper variables
NOW_TIME=$(date +"%s")
ONE_MONTH=$(expr 31 \* 24 \* 60 \* 60)
ONE_YEAR=$(expr 365 \* 24 \* 60 \* 60)

MONTH_AGO=$(expr $NOW_TIME - $ONE_MONTH)
YEAR_AGO=$(expr $NOW_TIME - $ONE_YEAR)

JSON_HEADER="Content-Type: application/json"

declare -a TAGS_TO_BE_DELETED=()

# Helper for logging into Docker Hub
login_data() {
cat <<EOF
{
  "username": "$DOCKER_USER",
  "password": "$DOCKER_AUTH"
}
EOF
}

# Does list contain an item
# Note: example: prod will match prod and prod-yyyy-mm-dd
function contains() {
  local n=$#
  local value=${!n}
  for ((i=1;i < $#;i++)) {
      if [[ $value.* =~ ${!i} ]]; then
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
  # TODO: Enable authentication
  # TOKEN=`curl -s -H "$JSON_HEADER" -X POST -d "$(login_data)" "https://hub.docker.com/v2/users/login/" | jq -r .token`
  AUTH_HEADER="Authorization: JWT ${TOKEN}"
  echo "Cleaning repository: ${NAME}"

  unset TAGS_TO_BE_DELETED

  # Get tags for a repository (paginated)
  URL="https://hub.docker.com/v2/repositories/${NAME}/tags/"
  JSON_RESPONSE=`curl -s "$URL" -X GET -H "$AUTH_HEADER" -H "$JSON_HEADER"`
  # Total count vs results on first page
  TOTAL_COUNT=$(jq -r .count <<< "$JSON_RESPONSE")
  RESULT_COUNT=$(jq -r '.results | length' <<< "$JSON_RESPONSE")
  # We go from last page to first if there are more pages!
  if [ $(jq -r .next <<< "$JSON_RESPONSE") != "null" ]; then
    LAST_PAGE=$(expr $(expr $TOTAL_COUNT + $RESULT_COUNT - 1) / $RESULT_COUNT)
    PREV_URL="${URL}?page=${LAST_PAGE}"
  else
    PREV_URL="${URL}"
  fi

  sleep 1

  # We will keep track of current year and month to track changes!
  CURRENT_YEAR=""
  CURRENT_MONTH=""
  MONTH_CHANGED=false
  YEAR_CHANGED=false

  echo "  Inspect:"
  # Repeat through the repository
  while [ "$PREV_URL" != "null" ]
  do
    echo "    Page: ${PREV_URL}"

    # Get tags for a repository (paginated)
    JSON_RESPONSE=`curl -s "$PREV_URL" -X GET -H "$AUTH_HEADER" -H "$JSON_HEADER"`
    # Extract next url
    PREV_URL=$(jq -r .previous <<< "$JSON_RESPONSE")

    # Loop through the results from current page, (no subshell)
    while read result;
    do
      DELETE=false

      # Current tag
      TAG=$(jq -r .name <<< "$result")
      
      # Do not process this TAG if found in the array
      if [ $(contains "${SKIP_TAGS[@]}" "$TAG") == "y" ]; then
        echo "      Skipping: ${TAG}"
      else
        echo "      Checking: ${TAG}"
        
        # Info about tag's date
        TAG_UPDATED=$(jq -r .last_updated <<< "$result")
        TAG_EPOCH=$(date -d "${TAG_UPDATED}" +"%s")
        TAG_YEAR=$(date -d "${TAG_UPDATED}" +"%y")
        TAG_MONTH=$(date -d "${TAG_UPDATED}" +"%-m")

        # Reset change
        YEAR_CHANGED=false
        MONTH_CHANGED=false

        # Init these variables if empty (first tag to be processed)
        if [ -z $CURRENT_YEAR ]; then
          CURRENT_YEAR="${TAG_YEAR}"
          YEAR_CHANGED=true
        fi
        if [ -z $CURRENT_MONTH ]; then
          CURRENT_MONTH="${TAG_MONTH}"
          MONTH_CHANGED=true
        fi

        # Track changes in years and months
        if [ "$CURRENT_YEAR" -ne "$TAG_YEAR" ]; then
          CURRENT_YEAR="${TAG_YEAR}"
          YEAR_CHANGED=true
          # echo "Year changed!"
        fi
        if [ "$CURRENT_MONTH" -ne "$TAG_MONTH" ]; then
          CURRENT_MONTH="${TAG_MONTH}"
          MONTH_CHANGED=true
          # echo "Month changed!"
        fi

        # Check age when not first of year or month
        if [ "$TAG_EPOCH" -lt "$YEAR_AGO" ] && [ "$YEAR_CHANGED" == false ]; then
          echo "        --> More than one year old"
          DELETE=true
        elif [ "$TAG_EPOCH" -lt "$MONTH_AGO" ] && [ "$MONTH_CHANGED" == false ]; then
          echo "        --> More than one month old"
          DELETE=true
        else
          # We do nothing for recent tags
          DELETE=false
        fi

        # Add for deletion
        if [ "$DELETE" == true ]; then
          TAGS_TO_BE_DELETED+=("${TAG}")
        fi

      fi

      sleep 1
    
    done <<< $(jq -c '.results | reverse[]' <<< "$JSON_RESPONSE")

    sleep 1

  done

  echo "  Delete:"
  # Delete the tags
  for DELETE_TAG in "${TAGS_TO_BE_DELETED[@]}"
  do
    echo "    Deleting: ${DELETE_TAG}"
    # TODO: ENABLE DELETION
    # curl "https://hub.d_remove_this_docker.com/v2/repositories/${NAME}/tags/${DELETE_TAG}/" -X DELETE -H "$AUTH_HEADER"
    sleep 1
  done

done


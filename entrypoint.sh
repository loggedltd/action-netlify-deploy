#!/bin/bash

set -e

# Install netlify globally before NVM to prevent EACCESS issues
npm i -g netlify-cli

# Save its exec path to run later
NETLIFY_CLI=$(which netlify)

NETLIFY_AUTH_TOKEN=$1
NETLIFY_SITE_ID=$2
NETLIFY_DEPLOY_TO_PROD=$3
DEPLOY_ALIAS=$4
WORKING_DIRECTORY=$5


if [[ $WORKING_DIRECTORY != "" ]]
then
	cd $WORKING_DIRECTORY
fi

# Export token to use with netlify's cli
export NETLIFY_SITE_ID="$NETLIFY_SITE_ID"
export NETLIFY_AUTH_TOKEN="$NETLIFY_AUTH_TOKEN"

COMMAND="$NETLIFY_CLI deploy --message=\"$INPUT_NETLIFY_DEPLOY_MESSAGE\""

if [[ $NETLIFY_DEPLOY_TO_PROD == "true" ]]
then
	COMMAND+=" --prod"
elif [[ -n $DEPLOY_ALIAS ]]
then
	COMMAND+=" --alias $DEPLOY_ALIAS"
fi

# Deploy with netlify
OUTPUT=$(sh -c "$COMMAND")

NETLIFY_OUTPUT=$(echo "$OUTPUT")
NETLIFY_PREVIEW_URL=$(echo "$OUTPUT" | grep -Eo '(http|https)://[a-zA-Z0-9./?=_-]*(--)[a-zA-Z0-9./?=_-]*') #Unique key: --
NETLIFY_LOGS_URL=$(echo "$OUTPUT" | grep -Eo '(http|https)://app.netlify.com/[a-zA-Z0-9./?=_-]*') #Unique key: app.netlify.com
NETLIFY_LIVE_URL=$(echo "$OUTPUT" | grep -Eo '(http|https)://[a-zA-Z0-9./?=_-]*' | grep -Eov "netlify.com") #Unique key: don't containr -- and app.netlify.com

echo "::set-output name=NETLIFY_OUTPUT::$NETLIFY_OUTPUT"
echo "::set-output name=NETLIFY_PREVIEW_URL::$NETLIFY_PREVIEW_URL"
echo "::set-output name=NETLIFY_LOGS_URL::$NETLIFY_LOGS_URL"
echo "::set-output name=NETLIFY_LIVE_URL::$NETLIFY_LIVE_URL"

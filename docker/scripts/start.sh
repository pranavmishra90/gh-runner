#!/bin/bash

# $GH_OWNER_REPO is the full org_name/repo 
GH_OWNER_REPO=$GH_OWNER_REPO
GH_TOKEN=$GH_TOKEN
SERVERNAME=$SERVERNAME

RUNNER_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)

# The runner's name prefix can be defined by an environment variable "SERVERNAME"
RUNNER_NAME="$SERVERNAME-Node-$RUNNER_SUFFIX"



REG_TOKEN=$(curl -sL -X POST -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" -H "Authorization: Bearer $GH_TOKEN"  https://api.github.com/orgs/$GH_OWNER_REPO/actions/runners/registration-token | jq .token --raw-output)

cd /home/docker/actions-runner

./config.sh --unattended --url https://github.com/$GH_OWNER_REPO --token $REG_TOKEN --name $RUNNER_NAME

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token $REG_TOKEN
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
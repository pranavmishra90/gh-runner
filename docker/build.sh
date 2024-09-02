#!/bin/bash


# Report errors and exit if detected
trap 'echo "Error on line $LINENO: $BASH_COMMAND"; exit 1' ERR
set -e

source  ~/miniforge3/etc/profile.d/conda.sh
conda activate base

echo "Conda environment: $(conda info --envs | grep '*' | awk '{print $1}')"
iso_datetime=$(date +"%Y-%m-%dT%H:%M:%S%z")


# Choose a version number ---------------------------------------------------------------------------------

# Detect the semantic release version number
cd $(git rev-parse --show-toplevel)
semvar_version=$(semantic-release version --print 2>/dev/null)


# Go back into the docker directory
cd docker

# We may read the "image_version.txt" if we cannot get a semantic release version
version_file="image_version.txt"

if git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Semantic Release Auto Version: '$semvar_version'"

    if [ -n "$semvar_version" ]; then
        set_version=$semvar_version
        echo "$set_version" > "$version_file"

    else
        if [ -f "$version_file" ]; then
            set_version=$(<"$version_file" tr -d '[:space:]')
        else
            echo "Warning: $version_file not found. Using 'dev' as default."
            set_version="dev"
        fi
    fi
else
    echo "Not a Git repository. Using $version_file or 'dev' as default."
    if [ -f "$version_file" ]; then
        set_version=$(<"$version_file" tr -d '[:space:]')
    else
        echo "Warning: $version_file not found. Using 'dev' as default."
        set_version="dev"
    fi
fi


iso_datetime=$(date +"%Y-%m-%dT%H:%M:%S%z")
echo "building Version: $set_version || Timestamp $iso_datetime"

sleep 10

# Write these values to the env file
echo "ISO_DATETIME=$iso_datetime" > .env
echo "IMAGE_VERSION=$set_version" >> .env

# Build and push the base image
docker compose -f docker-compose.yaml build facsimilab ubuntu --push \
    --build-arg IMAGE_VERSION=$set_version \
    --build-arg ISO_DATETIME=$iso_datetime \
    --build-arg RUNNER_VERSION='2.319.1'

docker push pranavmishra90/gh-runner-selfhosted:ubuntu
docker push -q pranavmishra90/gh-runner-selfhosted:ubuntu-v$set_version
docker push pranavmishra90/gh-runner-selfhosted:facsimilab
docker push -q pranavmishra90/gh-runner-selfhosted:facsimilab-v$set_version
docker push -q pranavmishra90/gh-runner-selfhosted:latest


# Play an alert tone in the terminal to mark completion'
echo -e '\a'

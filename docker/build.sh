#!/bin/bash

# docker buildx create --name cuda --node cuda --use --bootstrap --driver-opt network=docker-local-reg
# docker buildx create --name main --node bk15 --use --bootstrap --driver-opt network=docker-local-reg

iso_datetime=$(date +"%Y-%m-%dT%H:%M:%S%z")

docker_dir=$docker_dir

cd $docker_dir/gh-runner

pwd


docker buildx build \
  --add-host registry:172.100.0.100 \
  --build-arg RUNNER_VERSION='2.319.1' \
  --build-arg ISO_DATETIME=$iso_datetime \
  --build-arg CACHEBUST="${CACHEBUST:-$(date +%s)}" \
  --cache-from type=registry,mode=max,oci-mediatypes=true,ref=pranavmishra90/gh-runner-selfhosted:latest \
  --cache-from type=registry,mode=max,oci-mediatypes=true,ref=pranavmishra90/gh-runner-selfhosted:buildcache \
  --output type=registry,push=true,name=pranavmishra90/gh-runner-selfhosted:latest \
	--output type=registry,push=true,name=pranavmishra90/gh-runner-selfhosted:facsimilab \
	--output type=docker,name=pranavmishra90/gh-runner-selfhosted:latest \
	--output type=docker,name=pranavmishra90/gh-runner-selfhosted:facsimilab \
  . -f facsimilab.dockerfile

docker buildx build \
  --add-host registry:172.100.0.100 \
  --build-arg RUNNER_VERSION='2.319.1' \
  --build-arg ISO_DATETIME=$iso_datetime \
  --build-arg CACHEBUST="${CACHEBUST:-$(date +%s)}" \
  --cache-from type=registry,mode=max,oci-mediatypes=true,ref=pranavmishra90/gh-runner-selfhosted:buildcache \
  --output type=registry,push=true,name=pranavmishra90/gh-runner-selfhosted:ubuntu \
	--output type=docker,name=pranavmishra90/gh-runner-selfhosted:ubuntu \
  . -f ubuntu.dockerfile

# Play an alert tone in the terminal to mark completion'
echo -e '\a'

#!/bin/bash
docker compose down
docker compose -f run-docker-compose.yaml   up -d --scale ghrunner=3
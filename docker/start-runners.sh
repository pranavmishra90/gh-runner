#!/bin/bash
docker compose down
docker compose up --scale ghrunner=3 -d 
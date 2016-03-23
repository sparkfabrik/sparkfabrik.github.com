#!/bin/bash
if [ -z "$1" ]
then
  CMD="ash"
else
  CMD=$1
fi
docker-compose run --rm hugo $CMD

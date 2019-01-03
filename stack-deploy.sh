#!/usr/bin/env bash
docker-compose -f docker-stack.yml config > ./docker-stack-run.yml
docker stack deploy -c=./docker-stack-run.yml crcms-microservice

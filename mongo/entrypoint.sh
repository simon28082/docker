#!/usr/bin/env bash

mongo_config=${MONGO_CONFIG}/mongod.conf

mongod --config ${mongo_config}

exec "$@"
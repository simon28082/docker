#!/bin/sh

if [[ "${RUN_ENV}" = "production" || "${RUN_ENV}" = "" ]]; then
    CONSUL_CONF_PATH="/consul/config/config-production"
else
    CONSUL_CONF_PATH="/consul/config/config-${RUN_ENV}"
fi

consul agent -config-format=json -config-dir=${CONSUL_CONF_PATH}
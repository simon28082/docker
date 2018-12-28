#!/usr/bin/env bash

chown ${APP_RUN_PUID}:${APP_RUN_PGID} -R ${CONTAINER_CODE_PATH}

if [[ "${RUN_ENV}" = 'production' || "${RUN_ENV}" = "" ]]; then
    SOURCE_PATH=${CONTAINER_DOCKER_PATH}/nginx/nginx-production.conf
else
    SOURCE_PATH=${CONTAINER_DOCKER_PATH}/nginx/nginx-${RUN_ENV}.conf
fi

NGINX_RUN_CONF=${CONTAINER_DOCKER_PATH}/nginx/nginx-run.conf

cat ${SOURCE_PATH} \
| sed "s#\${APP_RUN_NAME}#${APP_RUN_NAME}#g" \
| sed "s#\${PHP_FPM_PORT}#${PHP_FPM_PORT}#g" \
| sed "s#\${CONTAINER_CODE_PATH}#${CONTAINER_CODE_PATH}#g" \
> ${NGINX_RUN_CONF}

nginx -g "daemon off;" -c ${NGINX_RUN_CONF}
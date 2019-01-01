#!/usr/bin/env bash

chown ${APP_RUN_PUID}:${APP_RUN_PGID} -R ${CONTAINER_CODE_PATH}

NGINX_RUN_CONFIG=${NGINX_CONFIG}/${RUN_ENV}/nginx.conf

if [ ! -f "${NGINX_RUN_CONFIG}" ]; then
    NGINX_RUN_CONFIG=/etc/nginx/nginx.conf
fi

nginx -g "daemon off;" -c ${NGINX_RUN_CONFIG}

exec "$@"
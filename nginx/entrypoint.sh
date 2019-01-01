#!/usr/bin/env bash

chown ${APP_RUN_PUID}:${APP_RUN_PGID} -R ${CONTAINER_CODE_PATH}

NGINX_BUILD_CONFIG=${NGINX_CONFIG}/${RUN_ENV}/nginx.conf

if [ ! -f "${NGINX_BUILD_CONFIG}" ]; then
    NGINX_BUILD_CONFIG=/etc/nginx/nginx.conf
fi

NGINX_RUN_CONFIG=$(dirname "${NGINX_BUILD_CONFIG}")/nginx-run.conf

cat ${NGINX_BUILD_CONFIG} \
| sed "s#\${APP_RUN_NAME}#${APP_RUN_NAME}#g" \
| sed "s#\${PHP_FPM_PORT}#${PHP_FPM_PORT}#g" \
| sed "s#\${CONTAINER_CODE_PATH}#${CONTAINER_CODE_PATH}#g" \
> ${NGINX_RUN_CONFIG}

nginx -g "daemon off;" -c ${NGINX_RUN_CONFIG}

exec "$@"
#!/usr/bin/env bash

chown ${APP_RUN_PUID}:${APP_RUN_PGID} -R ${CONTAINER_CODE_PATH}

nginx_build_config=${NGINX_CONFIG}/nginx.conf

if [ ! -f "${nginx_build_config}" ]; then
    nginx_build_config=/etc/nginx/nginx.conf
fi

nginx_run_config=$(dirname "${nginx_build_config}")/nginx-run.conf

cat ${nginx_build_config} \
| sed "s#\${APP_RUN_NAME}#${APP_RUN_NAME}#g" \
| sed "s#\${PHP_FPM_PORT}#${PHP_FPM_PORT}#g" \
| sed "s#\${CONTAINER_CODE_PATH}#${CONTAINER_CODE_PATH}#g" \
> ${nginx_run_config}

nginx -g "daemon off;" -c ${nginx_run_config}

exec "$@"
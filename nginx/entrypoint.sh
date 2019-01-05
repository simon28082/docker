#!/usr/bin/env bash

chown ${APP_RUN_PUID}:${APP_RUN_PGID} -R ${CONTAINER_CODE_PATH}

nginx_build_config=${NGINX_CONFIG}/nginx.conf

if [ ! -f "${nginx_build_config}" ]; then
    nginx_build_config=/etc/nginx/nginx.conf
fi

nginx_run_config=/var/nginx-run.conf

cat ${nginx_build_config} \
| sed "s#\${APP_RUN_NAME}#${APP_RUN_NAME}#g" \
| sed "s#\${PHP_FPM_PORT}#${PHP_FPM_PORT}#g" \
| sed "s#\${CONTAINER_CODE_PATH}#${CONTAINER_CODE_PATH}#g" \
> ${nginx_run_config}

# vhost conf replace
if [ -d "${NGINX_CONFIG}/vhosts" ]; then
    mkdir -p /var/vhosts
    for current_file in $(ls "${NGINX_CONFIG}/vhosts")
    do
        if test -f "${NGINX_CONFIG}/vhosts/${current_file}"
        then
            cat "${NGINX_CONFIG}/vhosts/${current_file}" \
            | sed "s#\${APP_RUN_NAME}#${APP_RUN_NAME}#g" \
            | sed "s#\${PHP_FPM_PORT}#${PHP_FPM_PORT}#g" \
            | sed "s#\${CONTAINER_CODE_PATH}#${CONTAINER_CODE_PATH}#g" \
            > "/var/vhosts/${current_file}"
        fi
    done
fi

nginx -g "daemon off;" -c ${nginx_run_config}

exec "$@"
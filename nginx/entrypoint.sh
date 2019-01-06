#!/usr/bin/env bash

chown ${APP_RUN_PUID}:${APP_RUN_PGID} -R ${CONTAINER_CODE_PATH}

nginx_build_config=${NGINX_CONFIG}/nginx.conf
nginx_build_vhost_path=${NGINX_CONFIG}/vhosts

if [ ! -f "${nginx_build_config}" ]; then
    nginx_build_config=/etc/nginx/nginx.conf
fi

nginx_run_config=/var/run/nginx-run.conf
nginx_run_vhost_path=/var/run/vhosts

cat ${nginx_build_config} \
| sed "s#\${APP_RUN_NAME}#${APP_RUN_NAME}#g" \
| sed "s#\${PHP_FPM_PORT}#${PHP_FPM_PORT}#g" \
| sed "s#\${CONTAINER_CODE_PATH}#${CONTAINER_CODE_PATH}#g" \
> ${nginx_run_config}

# vhost conf replace
if [ -d "${nginx_build_vhost_path}" ]; then
    mkdir -p ${nginx_run_vhost_path}
    for current_file in $(ls "${nginx_build_vhost_path}")
    do
        if test -f "${nginx_build_vhost_path}/${current_file}"
        then
            cat "${nginx_build_vhost_path}/${current_file}" \
            | sed "s#\${APP_RUN_NAME}#${APP_RUN_NAME}#g" \
            | sed "s#\${PHP_FPM_PORT}#${PHP_FPM_PORT}#g" \
            | sed "s#\${CONTAINER_CODE_PATH}#${CONTAINER_CODE_PATH}#g" \
            > "${nginx_run_vhost_path}/${current_file}"
        fi
    done
fi

nginx -g "daemon off;" -c ${nginx_run_config}

exec "$@"
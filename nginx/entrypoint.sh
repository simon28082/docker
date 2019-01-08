#!/usr/bin/env bash

#### functions ####

# new environment variable user definition
createRunUserAndGroupIfNotExists(){
    local new_user=${1}
    local new_group=${2}
    local new_user_id=${3}
    local new_user_gid=${4}

    #create group if not exists
    egrep "^${new_group}" /etc/group >& /dev/null
    if [ $? -eq 1 ]; then
        groupadd -g ${4} ${2}
    fi

    id ${new_user} >& /dev/null
    if [ $? -eq 1 ]; then
       useradd -u ${3} -g ${4} ${1} && \
       usermod -s /sbin/nologin ${1}
    fi
}

# auto mount
autoMount(){
    local mount_path=${1}
    if [ -f "${mount_path}" ]; then
        bash ${mount_path}
    fi
}

# create user
createRunUserAndGroupIfNotExists ${APP_RUN_NAME} ${APP_RUN_GROUP} ${APP_RUN_PUID} ${APP_RUN_PGID}

#chown
chown ${APP_RUN_NAME}:${APP_RUN_GROUP} -R ${CONTAINER_CODE_PATH}

# mount
autoMount ${NGINX_CONFIG}/mount.sh

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
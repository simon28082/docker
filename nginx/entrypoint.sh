#!/usr/bin/env bash

#### functions ####
default_user='crcms'
default_group='crcms'
default_user_id=1000
default_group_gid=1000
# new environment variable user definition
createRunUserAndGroupIfNotExists(){
    local new_user=${1}
    local new_group=${2}
    local new_user_id=${3}
    local new_group_gid=${4}

    local group_exists=`cat /etc/group | cut -f 1 -d ':' | grep -w "^${new_group}$" -c`
    if [ ${group_exists} -le 0 ]; then
        groupmod -n ${new_group} ${default_group}
    fi

    local group_gid_exists=`cat /etc/group | cut -f 3 -d ':' | grep -w "^${new_group_gid}$" -c`
    if [ ${group_gid_exists} -le 0 ]; then
        groupmod -g ${new_group_gid} ${new_group}
    fi

    local user_exists=`cat /etc/passwd | cut -f 1 -d ':' | grep -w "^${new_user}$" -c`
    if [ ${user_exists} -le 0 ]; then
        usermod -l ${new_user} -d /home/${new_user} -m ${default_user}
    fi

    local user_id_exists=`cat /etc/passwd | cut -f 3 -d ':' | grep -w "^${new_user_id}$" -c`
    if [ ${user_id_exists} -le 0 ]; then
        usermod -u ${new_user_id} ${new_user}
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

# change user and group
chown ${APP_RUN_PUID}:${APP_RUN_PGID} -R ${CONTAINER_CODE_PATH}

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
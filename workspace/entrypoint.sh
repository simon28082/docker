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

# rsyslog start
service rsyslog restart

# change user and group
createRunUserAndGroupIfNotExists ${APP_RUN_NAME} ${APP_RUN_GROUP} ${APP_RUN_PUID} ${APP_RUN_PGID}

#supervisor
supervisor_exists=`whereis supervisord`
if [ "${supervisor_exists}" = 'supervisord: /usr/bin/supervisord' ]; then
    # supervisord
    /usr/bin/python /usr/bin/supervisord -c ${WORKSPACE_CONFIG}/supervisord.conf &
fi

#crontab
workspace_crontab_config=${WORKSPACE_CONFIG}/crontab
if [ -f "/etc/crontab" -a -f "${workspace_crontab_config}" ]; then
    cat ${workspace_crontab_config} \
    | sed "s#\${CONTAINER_CODE_PATH}#${CONTAINER_CODE_PATH}#g" \
    | sed "s#\${APP_RUN_NAME}#${APP_RUN_NAME}#g" > /etc/crontab

    # Automatically append line breaks to solve Missing newline before EOF problem
    echo -e "\n" >> /etc/crontab

    # run cron without daemon mode
    # in docker container service cron restart crontab not executed
    # /usr/sbin/cron -f &
    service cron restart
fi

#chown
chown ${APP_RUN_PUID}:${APP_RUN_PGID} -R ${CONTAINER_CODE_PATH}

# mount
autoMount ${WORKSPACE_CONFIG}/mount.sh

exec "$@"

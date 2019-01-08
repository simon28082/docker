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


#supervisor
supervisor_exists=`whereis supervisord`
if [ "${supervisor_exists}" = 'supervisord: /usr/bin/supervisord' ]; then
    # supervisord
    /usr/bin/python /usr/bin/supervisord -c ${WORKSPACE_CONFIG}/supervisord.conf &
fi

workspace_crontab_config=${WORKSPACE_CONFIG}/crontab
#crontab
if [ -f "/etc/crontab" -a -f "${workspace_crontab_config}" ]; then
    cat ${workspace_crontab_config} \
    | sed "s#\${CONTAINER_CODE_PATH}#${CONTAINER_CODE_PATH}#g" \
    | sed "s#\${APP_RUN_NAME}#${APP_RUN_NAME}#g" > /etc/crontab
fi

# create user
createRunUserAndGroupIfNotExists ${APP_RUN_NAME} ${APP_RUN_GROUP} ${APP_RUN_PUID} ${APP_RUN_PGID}

#chown
chown ${APP_RUN_NAME}:${APP_RUN_GROUP} -R ${CONTAINER_CODE_PATH}

# mount
autoMount ${WORKSPACE_CONFIG}/mount.sh

exec "$@"
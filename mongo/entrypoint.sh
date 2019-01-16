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

# create user
createRunUserAndGroupIfNotExists ${APP_RUN_NAME} ${APP_RUN_GROUP} ${APP_RUN_PUID} ${APP_RUN_PGID}

mongo_config=${MONGO_CONFIG}/mongod.conf

mongod --config ${mongo_config}

exec "$@"
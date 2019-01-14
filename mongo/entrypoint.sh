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

# create user
createRunUserAndGroupIfNotExists ${APP_RUN_NAME} ${APP_RUN_GROUP} ${APP_RUN_PUID} ${APP_RUN_PGID}

mongo_config=${MONGO_CONFIG}/mongod.conf

mongod --config ${mongo_config}

exec "$@"
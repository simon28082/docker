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
autoMount ${PHP_FPM_CONFIG}/mount.sh

php_ini_config_path=${PHP_FPM_CONFIG}/php.ini
php_fpm_config_path=${PHP_FPM_CONFIG}/php-fpm.conf
php_ini_config_run_path=/var/run/php-run.ini
php_fpm_config_run_path=/var/run/php-fpm-run.conf

if [ ! -f "${php_ini_config_path}" ]; then
    php_ini_config_path=/usr/local/etc/php/php.ini-production
fi

if [ ! -f "${php_fpm_config_path}" ]; then
    php_fpm_config_path=/usr/local/etc/php-fpm.conf
fi

# build config
cat "${php_ini_config_path}" \
| sed "s#\${APP_RUN_NAME}#${APP_RUN_NAME}#g" \
| sed "s#\${APP_RUN_GROUP}#${APP_RUN_GROUP}#g" \
> "${php_ini_config_run_path}"

cat "${php_fpm_config_path}" \
| sed "s#\${APP_RUN_NAME}#${APP_RUN_NAME}#g" \
| sed "s#\${APP_RUN_GROUP}#${APP_RUN_GROUP}#g" \
> "${php_fpm_config_run_path}"

# run
php-fpm -c ${php_ini_config_run_path} -y ${php_fpm_config_run_path}

# clean opcache
php -r 'if(function_exists("opcache_reset")) {opcache_reset();}'

exec "$@"
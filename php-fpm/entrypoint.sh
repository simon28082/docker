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

# change user and group
createRunUserAndGroupIfNotExists ${APP_RUN_NAME} ${APP_RUN_GROUP} ${APP_RUN_PUID} ${APP_RUN_PGID}

#chown
chown ${APP_RUN_PUID}:${APP_RUN_PGID} -R ${CONTAINER_CODE_PATH}

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
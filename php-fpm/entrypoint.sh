#!/usr/bin/env bash

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

# chown
chown ${APP_RUN_PUID}:${APP_RUN_PGID} -R ${CONTAINER_CODE_PATH}

# build

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
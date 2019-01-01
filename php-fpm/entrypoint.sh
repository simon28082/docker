#!/usr/bin/env bash

PHP_INI_CONFIG_PATH=${PHP_FPM_CONFIG}/${RUN_ENV}/php.ini
PHP_FPM_CONFIG_PATH=${PHP_FPM_CONFIG}/${RUN_ENV}/php-fpm.conf

if [ ! -f "${PHP_INI_CONFIG_PATH}" ]; then
    PHP_INI_CONFIG_PATH=/usr/local/etc/php/php.ini-production
fi

if [ ! -f "${PHP_FPM_CONFIG_PATH}" ]; then
    PHP_FPM_CONFIG_PATH=/usr/local/etc/php-fpm.conf
fi

chown ${APP_RUN_PUID}:${APP_RUN_PGID} -R ${CONTAINER_CODE_PATH}

# run
php-fpm -c ${PHP_INI_CONFIG_PATH} -y ${PHP_FPM_CONFIG_PATH}

# clean opcache
php -r 'if(function_exists("opcache_reset")) {opcache_reset();}'

exec "$@"
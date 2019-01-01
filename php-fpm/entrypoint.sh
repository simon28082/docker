#!/usr/bin/env bash

PHP_INI_CONFIG_PATH=${PHP_FPM_CONFIG}/php.ini
PHP_FPM_CONFIG_PATH=${PHP_FPM_CONFIG}/php-fpm.conf
PHP_INI_CONFIG_RUN_PATH=${PHP_FPM_CONFIG}/php-run.ini
PHP_FPM_CONFIG_RUN_PATH=${PHP_FPM_CONFIG}/php-fpm-run.conf


if [ ! -f "${PHP_INI_CONFIG_PATH}" ]; then
    PHP_INI_CONFIG_PATH=/usr/local/etc/php/php.ini-production
fi

if [ ! -f "${PHP_FPM_CONFIG_PATH}" ]; then
    PHP_FPM_CONFIG_PATH=/usr/local/etc/php-fpm.conf
fi

# chown
chown ${APP_RUN_PUID}:${APP_RUN_PGID} -R ${CONTAINER_CODE_PATH}

# build

cat "${PHP_INI_CONFIG_PATH}" \
| sed "s#\${APP_RUN_NAME}#${APP_RUN_NAME}#g" \
| sed "s#\${APP_RUN_GROUP}#${APP_RUN_GROUP}#g" \
> "${PHP_INI_CONFIG_RUN_PATH}"

cat "${PHP_FPM_CONFIG_PATH}" \
| sed "s#\${APP_RUN_NAME}#${APP_RUN_NAME}#g" \
| sed "s#\${APP_RUN_GROUP}#${APP_RUN_GROUP}#g" \
> "${PHP_FPM_CONFIG_RUN_PATH}"

# run
php-fpm -c ${PHP_INI_CONFIG_RUN_PATH} -y ${PHP_FPM_CONFIG_RUN_PATH}

# clean opcache
php -r 'if(function_exists("opcache_reset")) {opcache_reset();}'

exec "$@"
FROM php:7.2-fpm


MAINTAINER simon


#### global common #############################
ARG ARG_RUN_ENV=production
ENV RUN_ENV=${ARG_RUN_ENV}
ARG ARG_CONTAINER_CODE_PATH=/var/www
ENV CONTAINER_CODE_PATH=${ARG_CONTAINER_CODE_PATH}
ARG ARG_PHP_FPM_CONFIG=/config
ENV PHP_FPM_CONFIG=${ARG_PHP_FPM_CONFIG}


#### user and group #############################
ARG ARG_APP_RUN_PUID=1000
ARG ARG_APP_RUN_PGID=1000
ARG ARG_APP_RUN_NAME=crcms
ARG ARG_APP_RUN_GROUP=crcms
ENV APP_RUN_PUID=${ARG_APP_RUN_PUID}
ENV APP_RUN_PGID=${ARG_APP_RUN_PGID}
ENV APP_RUN_NAME=${ARG_APP_RUN_NAME}
ENV APP_RUN_GROUP=${ARG_APP_RUN_GROUP}

RUN groupadd -g ${ARG_APP_RUN_PGID} ${ARG_APP_RUN_GROUP} && \
    useradd -u ${ARG_APP_RUN_PUID} -g ${ARG_APP_RUN_PGID} ${ARG_APP_RUN_NAME} && \
    usermod -s /sbin/nologin ${ARG_APP_RUN_NAME}


#### set timezone #############################
ARG ARG_TIMEZONE=UTC
RUN ln -snf /usr/share/zoneinfo/${ARG_TIMEZONE} /etc/localtime && echo ${ARG_TIMEZONE} > /etc/timezone


#### software install #############################
RUN apt-get update -yqq \
    && pecl channel-update pecl.php.net


#### php pecl #############################
# base install
#pdo_mysql,opcache
RUN docker-php-ext-install pdo_mysql \
    && docker-php-ext-install opcache


# mongodb
ARG ARG_PHP_FPM_INSTALL_MONGODB=false
RUN if [ ${ARG_PHP_FPM_INSTALL_MONGODB} = true ]; then \
    pecl install mongodb \
    && docker-php-ext-enable mongodb \
;fi

# redis
ARG ARG_PHP_FPM_INSTALL_REDIS=false
RUN if [ ${ARG_PHP_FPM_INSTALL_REDIS} = true ]; then \
    pecl install redis \
    && docker-php-ext-enable redis \
;fi


### config #############################
# use workdir create dir
WORKDIR ${ARG_PHP_FPM_CONFIG}
COPY ./${ARG_RUN_ENV}/ ${ARG_PHP_FPM_CONFIG}


#### volume #############################
VOLUME ["${ARG_CONTAINER_CODE_PATH}"]


#### expose #############################
EXPOSE 9000/tcp


#### cmd #############################
COPY ./entrypoint.sh /usr/bin/entrypoint.sh
ENTRYPOINT ["/usr/bin/entrypoint.sh"]


#### workdir #############################
WORKDIR ${ARG_CONTAINER_CODE_PATH}
FROM nginx


MAINTAINER simon


#### global common #############################
ARG ARG_RUN_ENV=production
ENV RUN_ENV=${ARG_RUN_ENV}
ARG ARG_CONTAINER_CODE_PATH=/var/www
ENV CONTAINER_CODE_PATH=${ARG_CONTAINER_CODE_PATH}
ARG ARG_NGINX_CONFIG=/config
ENV NGINX_CONFIG=${ARG_NGINX_CONFIG}


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


### config #############################
# use workdir create dir
WORKDIR ${ARG_NGINX_CONFIG}
COPY ./${ARG_RUN_ENV}/*.conf ${ARG_NGINX_CONFIG}


#### volume #############################
VOLUME ["${ARG_CONTAINER_CODE_PATH}"]


#### expose #############################
EXPOSE 80/tcp
EXPOSE 443/tcp


#### cmd #############################
COPY ./entrypoint.sh /usr/bin/entrypoint.sh
ENTRYPOINT ["/usr/bin/entrypoint.sh"]


#### workdir #############################
WORKDIR ${ARG_CONTAINER_CODE_PATH}
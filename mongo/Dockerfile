FROM mongo:latest


MAINTAINER simon


#### global common #############################
ARG ARG_RUN_ENV=production
ENV RUN_ENV=${ARG_RUN_ENV}
ARG ARG_MONGO_CONFIG=/config
ENV MONGO_CONFIG=${ARG_MONGO_CONFIG}


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


RUN apt-get update \
    && apt-get install -y procps


#### set timezone #############################
ARG ARG_TIMEZONE=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/${ARG_TIMEZONE} /etc/localtime && echo ${ARG_TIMEZONE} > /etc/timezone


#### config copy #############################
COPY ./${ARG_RUN_ENV} ${ARG_MONGO_CONFIG}


#### volume #############################
VOLUME ["/data/db", "/data/configdb"]


#### expose #############################
EXPOSE 27017/tcp


#### cmd #############################
COPY ./*.sh /usr/bin/
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["mongod"]

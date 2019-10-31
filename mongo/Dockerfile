FROM mongo:latest


MAINTAINER simon


#### global common #############################
ARG ARG_RUN_ENV=production
ENV RUN_ENV=${ARG_RUN_ENV}
ARG ARG_MONGO_CONFIG=/config
ENV MONGO_CONFIG=${ARG_MONGO_CONFIG}

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

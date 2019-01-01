FROM consul

MAINTAINER simon

#### global common #############################
ARG ARG_RUN_ENV=production
ENV RUN_ENV=${ARG_RUN_ENV}
ARG ARG_CONSUL_CONFIG=/config
ENV CONSUL_CONFIG=${ARG_CONSUL_CONFIG}
ARG ARG_CONSUL_DATA=/data


#### set timezone #############################
ARG ARG_TIMEZONE=UTC
RUN ln -snf /usr/share/zoneinfo/${ARG_TIMEZONE} /etc/localtime && echo ${ARG_TIMEZONE} > /etc/timezone


#### entrypoint and cmd #############################
COPY ./entrypoint.sh /usr/bin/entrypoint.sh
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
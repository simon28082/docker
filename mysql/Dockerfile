FROM mysql:latest

MAINTAINER simon

#### global common #############################
ARG ARG_RUN_ENV=production
ENV RUN_ENV=${ARG_RUN_ENV}

#### set timezone #############################
ARG ARG_TIMEZONE=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/${ARG_TIMEZONE} /etc/localtime && echo ${ARG_TIMEZONE} > /etc/timezone
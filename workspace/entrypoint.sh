#!/usr/bin/env bash

#supervisor
supervisor_exists=`whereis supervisord`
if [ "${supervisor_exists}" = 'supervisord: /usr/bin/supervisord' ]; then
    # supervisord
    /usr/bin/python /usr/bin/supervisord -c ${WORKSPACE_CONFIG}/supervisord.conf &
fi

workspace_crontab_config=${WORKSPACE_CONFIG}/crontab
#crontab
if [ -f "/etc/crontab" -a -f "${workspace_crontab_config}" ]; then
    cat ${workspace_crontab_config} \
    | sed "s#\${CONTAINER_CODE_PATH}#${CONTAINER_CODE_PATH}#g" \
    | sed "s#\${APP_RUN_NAME}#${APP_RUN_NAME}#g" > /etc/crontab
fi

#chown
chown ${APP_RUN_PUID}:${APP_RUN_PGID} -R ${CONTAINER_CODE_PATH}/../


exec "$@"
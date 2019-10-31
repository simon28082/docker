#!/bin/bash

set -e

#mysql_replication_password=$(cat ${MYSQL_REPLICATION_PASSWORD_FILE})
#mysql_password=$(cat ${MYSQL_ROOT_PASSWORD_FILE})

mysql_replication_password=${MYSQL_REPLICATION_PASSWORD}
mysql_password=${MYSQL_ROOT_PASSWORD}

mysql -u root -p${mysql_password} \
-e "change master to master_host='mysql',master_user='${MYSQL_REPLICATION_USER}',master_password='${mysql_replication_password}',master_port=3306,master_auto_position=1,master_delay=${MYSQL_SLAVE_DELAY};
start slave;show slave status\G;"
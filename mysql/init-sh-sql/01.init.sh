#!/bin/bash

set -e

mysql_replication_password=${MYSQL_REPLICATION_PASSWORD}
mysql_password=${MYSQL_ROOT_PASSWORD}
mysql_net=$(hostname -i | sed "s/\.[0-9]\+$/.%/g")

mysql -u root -p${mysql_password} \
-e "create user '${MYSQL_REPLICATION_USER}'@'${mysql_net}' identified with mysql_native_password by '${mysql_replication_password}';
grant replication slave on *.* to '${MYSQL_REPLICATION_USER}'@'${mysql_net}';
flush privileges;show master status\G;"

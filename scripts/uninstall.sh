#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

if [ ! "$(systemctl status nginx | grep running)" ]; then
    systemctl stop nginx
fi
rm -rf /etc/nginx/conf.d/jumpserver.conf

if [ ! "$(systemctl status docker | grep running)" ]; then
    docker stop jms_koko jms_guacamole
    docker rm jms_koko jms_guacamole
    docker rmi wojiushixiaobai/jms_koko:$Version wojiushixiaobai/jms_guacamole:$Version
    systemctl stop docker
fi

if [ ! "$(systemctl status jms_core | grep running)" ]; then
    systemctl stop jms_core
fi
rm -rf /usr/lib/systemd/system/jms_core.service
rm -rf $install_dir/py3
rm -rf $install_dir/luna
rm -rf $install_dir/jumpserver

if [ $REDIS_HOST == 127.0.0.1 ]; then
    if [ ! "$(systemctl status redis | grep running)" ]; then
        redis-cli flushall
        systemctl stop redis
    fi
fi
if [ $DB_HOST == 127.0.0.1 ]; then
    if [ ! "$(systemctl status mariadb | grep running)" ]; then
        mysql -uroot -e"drop user '$DB_USER'@'$DB_HOST';drop database $DB_NAME;flush privileges;"
        systemctl stop mariadb
    fi
fi

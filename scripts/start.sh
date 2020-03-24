#!/usr/bin/env bash
#

if [ ! "$(systemctl status mariadb | grep running)" ]; then
    systemctl start mariadb
fi

if [ ! "$(systemctl status redis | grep running)" ]; then
    systemctl start redis
fi

if [ ! "$(systemctl status jms_core | grep running)" ]; then
    systemctl start jms_core
fi

if [ ! "$(systemctl status docker | grep running)" ]; then
    systemctl start docker
    docker start jms_koko jms_guacamole
fi

if [ ! "$(docker ps | grep jms_koko)" ]; then
    docker start jms_koko
fi
if [ ! "$(docker ps | grep jms_guacamole)" ]; then
    docker start jms_guacamole
fi

if [ ! "$(systemctl status nginx | grep running)" ]; then
    systemctl start nginx
fi

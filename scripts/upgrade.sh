#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

if [ ! -d "$install_dir/jumpserver" ]; then
    echo -e "\033[31m jumpserver 未安装或者目录不正确 \033[0m"
    exit 1
fi

Upgrade_Version=$(curl -s -L http://demo.jumpserver.org/download/latest)

if [ $Version == $Upgrade_Version ]; then
    echo -e "\033[31m $Version 已是最新版本 \033[0m"
    exit 0
fi

echo -e "\033[31m 准备从 $Version 升级到 $Upgrade_Version ... \033[0m"
jumpserver_backup=${PROJECT_DIR}/backup/$Version
if [ ! -d "$jumpserver_backup" ]; then
    mkdir -p $jumpserver_backup
fi

docker stop jms_koko jms_guacamole
docker rm jms_koko jms_guacamole
docker rmi wojiushixiaobai/jms_koko:$Version wojiushixiaobai/jms_guacamole:$Version
systemctl stop jms_core

if [ ! -d "$jumpserver_backup/jumpserver" ]; then
    cp $install_dir/jumpserver $jumpserver_backup/ -r
    echo -e "\033[31m >>> 已备份文件到 $jumpserver_backup <<< \033[0m"
fi
if [ ! -f "$jumpserver_backup/$DB_NAME.sql" ]; then
    mysqldump -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASSWORD $DB_NAME > $jumpserver_backup/$DB_NAME.sql
    echo -e "\033[31m >>> 已备份数据库到 $jumpserver_backup <<< \033[0m"
fi

cd $install_dir/jumpserver
git pull || {
    echo "\033[31m 获取 jumpserver 仓库更新失败 \033[0m"
    exit 1
}

source $install_dir/py3/bin/activate
pip install --upgrade pip setuptools
pip install -r $install_dir/jumpserver/requirements/requirements.txt || {
    echo "\033[31m 升级 python 依赖失败 \033[0m"
    exit 1
}

systemctl start jms_core

docker run --name jms_koko -d -p $ssh_port:2222 -p 127.0.0.1:5000:5000 -e CORE_HOST=http://$Server_IP:8080 -e BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN --restart=always wojiushixiaobai/jms_koko:$Upgrade_Version
docker run --name jms_guacamole -d -p 127.0.0.1:8081:8080 -e JUMPSERVER_SERVER=http://$Server_IP:8080 -e BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN --restart=always wojiushixiaobai/jms_guacamole:$Upgrade_Version

if [ ! -d "$PROJECT_DIR/$Upgrade_Version" ]; then
    mkdir -p $PROJECT_DIR/$Upgrade_Version
fi

cd $install_dir
rm -rf $install_dir/luna*

if [ ! -f "$PROJECT_DIR/$Upgrade_Version/luna.tar.gz" ]; then
    wget -O $PROJECT_DIR/$Upgrade_Version/luna.tar.gz http://demo.jumpserver.org/download/luna/$Upgrade_Version/luna.tar.gz
fi
tar -xf $PROJECT_DIR/$Upgrade_Version/luna.tar.gz -C $install_dir

sed -i "s/Version=$Version/Version=$Upgrade_Version/g" ${PROJECT_DIR}/config.conf
echo -e "\033[31m >>> 已升级版本至 $Upgrade_Version <<< \033[0m"

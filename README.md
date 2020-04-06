# jms_install
Jumpserver 安装脚本

官方安装文档 http://docs.jumpserver.org

本项目已经合并到官方项目 https://github.com/jumpserver/Dockerfile.git

后续不再更新, 请移至官方项目

Use:

```
cd /opt
git clone --depth=1 https://github.com/jumpserver/Dockerfile.git
cd Dockerfile
cp config_example.conf config.conf
vi config.conf
chmod +x ./jmsctl.sh
./jmsctl.sh -h
```
Install
```
./jmsctl.sh install
```
Uninstall
```
./jmsctl.sh uninstall
```
Help
```
./jmsctl.sh -h
```

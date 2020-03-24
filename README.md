# jms_install
Jumpserver 安装脚本

官方安装文档 http://docs.jumpserver.org

Use:

```
cd /opt
git clone --depth=1 https://github.com/wojiushixiaobai/jms_install.git
cd jms_install
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

#!/bin/bash

#sudo apt-get install libssl-dev
#
#wget -O /home/shell/nacos-server-1.3.2.tar.gz https://handson.oss-cn-shanghai.aliyuncs.com/nacos-server-1.3.2.tar.gz
#
#tar -xzvf /home/shell/nacos-server-1.3.2.tar.gz -C /home/shell/
#
#sh /home/shell/nacos/bin/startup.sh -m standalone

echo "begin install nacos ..."
sh ~/init_nacos.sh
echo "install nacos success ..."

echo "begin install mysql ..."
sleep 2
sh ~/init_mysql.sh
echo "install mysqll success ..."

echo "begin install seata-golang ..."
sleep 3
sh ~/seata-script/init_seatagolang.sh
echo "install seata-golang success ..."




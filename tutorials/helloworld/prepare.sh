#!/bin/bash

sudo apt-get install libssl-dev

wget -O /home/shell/nacos-server-1.3.2.tar.gz https://handson.oss-cn-shanghai.aliyuncs.com/nacos-server-1.3.2.tar.gz

tar -xzvf /home/shell/nacos-server-1.3.2.tar.gz -C /home/shell/

sh /home/shell/nacos/bin/startup.sh -m standalone
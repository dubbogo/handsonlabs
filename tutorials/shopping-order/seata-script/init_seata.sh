#!/bin/bash

wget -O /home/shell/seata-server-1.4.0.tar.gz https://handson.oss-cn-shanghai.aliyuncs.com/seata-server-1.4.0.tar.gz

tar -xzvf /home/shell/seata-server-1.4.0.tar.gz -C /home/shell/

sh /home/shell/seata-server/seata-server.sh -m /home/shell/seata-script/file.conf
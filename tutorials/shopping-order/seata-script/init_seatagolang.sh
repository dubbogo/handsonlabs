#!/bin/bash

git clone https://github.com/opentrx/seata-golang.git

cd /home/shell/seata-golang/cmd/tc
go build

mv tc /home/shell/seata-script/
cd /home/shell/seata-script/

./tc start -config /home/shell/seata-script/config.yml &

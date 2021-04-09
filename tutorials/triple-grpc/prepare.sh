#!/bin/sh
wget  https://github.com/dubbogo/resources/tree/master/zookeeper-4unitest/contrib/fatjar/zookeeper-3.4.9-fatjar.jar

tar -zxvf apache-zookeeper-3.7.0-bin.tar.gz

cd apache-zookeeper-3.7.0-bin

cd conf/

cp zoo_sample.cfg zoo.cfg

cd ..

cd bin/

sh zkServer.sh start
#!/bin/sh
wget https://mirrors.bfsu.edu.cn/apache/zookeeper/zookeeper-3.7.0/apache-zookeeper-3.7.0-bin.tar.gz

tar -zxvf apache-zookeeper-3.7.0-bin.tar.gz

cd apache-zookeeper-3.7.0-bin

cd conf/

cp zoo_sample.cfg zoo.cfg

cd ..

cd bin/

sh zkServer.sh start
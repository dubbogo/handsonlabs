#!/bin/bash
echo "start init mysql server"
echo "downloading mysql server ......"

mkdir /home/shell/log

wget https://handson.oss-cn-shanghai.aliyuncs.com/mysql-5.6.30-linux-glibc2.5-x86_64.tar.gz -O .mysql-5.6.30-linux-glibc2.5-x86_64.tar.gz

tar -xzvf .mysql-5.6.30-linux-glibc2.5-x86_64.tar.gz

mv mysql-5.6.30-linux-glibc2.5-x86_64 .mysql
mv mysql/mysqld.cnf .mysql/mysqld.cnf

cd .mysql

echo "installing mysql server ......"

./scripts/mysql_install_db --basedir=/home/shell/.mysql

echo "starting mysql server ......"

./bin/mysqld_safe --defaults-file=/home/shell/.mysql/mysqld.cnf &

sleep 5

echo "create database seata and init tables"
mysqladmin --defaults-file=/home/shell/.mysql/mysqld.cnf -uroot create seata
mysql --defaults-file=/home/shell/.mysql/mysqld.cnf -uroot < /home/shell/mysql/seata.sql

echo "create database seata_order and init tables"
mysqladmin --defaults-file=/home/shell/.mysql/mysqld.cnf -uroot create seata_order
mysql --defaults-file=/home/shell/.mysql/mysqld.cnf -uroot < /home/shell/mysql/seata_order.sql

echo "create database seata_product and init tables"
mysqladmin --defaults-file=/home/shell/.mysql/mysqld.cnf -uroot create seata_product
mysql --defaults-file=/home/shell/.mysql/mysqld.cnf -uroot < /home/shell/mysql/seata_product.sql

echo "init mysql server done"
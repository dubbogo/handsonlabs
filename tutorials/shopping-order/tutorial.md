# Dubbogo 与 Seata-golang 分布式事务场景案例

给个star鼓励一下我们吧： [github.com/apache/dubbo-go](https://github.com/apache/dubbo-go)

分布式事务：Seata-golang  [https://github.com/opentrx/seata-golang](https://github.com/opentrx/seata-golang) 



## 教程说明
通过该教程，你将会：

- Dubbogo 的基础功能体验
- Seata-golang 的基础功能体验
- 电商交易背景下基于Seata AT模式的分布式事务解决方案体验

依赖:
- [ ] nacos
- [ ] mysql
- [ ] seata-golang

请先准备依赖环境：

通过如下命令一键安装依赖服务（1~3min）
```bash
sh ~/prepare.sh
```

如有安装失败，本教程在“下一步”提供了各个依赖的安装脚本；


案例学习时间预计25分钟左右。


## 准备工作
本节，你将通过 git 命令下载程序代码，并启动 Nacos 服务端

### 获取客户端及服务端程序代码
请使用下面的命令获取客户端及服务端程序代码
```bash
git clone https://github.com/PhilYue/shopping-order.git -b feature/handsonlab
```

### 启动 Nacos 服务端(已自动安装，如果安装失败再自行安装)


通过如下命令启动nacos服务端
```bash
sh ~/init_nacos.sh
```

通过如下命令观察nacos启动日志:
```bash
cat /home/shell/nacos/logs/start.out
```

待出现如下输出时，代表启动完成（如果未完成启动，可以重复执行上一条命令）:
> INFO Tomcat started on port(s): 65000 (http) with context path '/nacos'<br>
> ......<br>
> INFO Nacos started successfully in stand alone mode. use embedded storage

### 安装 Mysql 并初始化数据库(已自动安装，如果安装失败再自行安装)

通过如下命令

```bash
sh ~/init_mysql.sh
```

### 安装启动 Seata-golang 服务端(已自动安装，如果安装失败再自行安装)

执行命令

```bash
sh ~/seata-script/init_seatagolang.sh
```

## 修改 Shopping-Order 配置(程序代码已经默认可直接运行)
本节，你将修改代码的一些基本配置，让程序可以运行。<br>
请认真按照本节的引导操作。在完成修改后，一定要记得保存哦。


### 修改服务端 Order 配置

**修改注册中心Nacos地址**
* 打开 <tutorial-editor-open-file filePath="/home/shell/shopping-order/go-server-order/conf/server.yml">服务端的 server.yml</tutorial-editor-open-file> 配置文件：
* 修改 `registries>nacos>address` Nacos 地址："127.0.0.1:65000"

**修改Seata数据库地址**
* 打开 <tutorial-editor-open-file filePath="/home/shell/shopping-order/go-server-order/conf/seata.yml">服务端的 seata.yml</tutorial-editor-open-file> 配置文件：
* 修改 `at>dsn` 数据库连接，无需密码 `root:@tcp(mysql:3306)/seata_order`
* 修改 `transaction_service_group` Seata 地址："127.0.0.1:8091"

### 修改服务端 Product 配置

**修改Seata数据库连接地址**
* 打开 <tutorial-editor-open-file filePath="/home/shell/shopping-order/go-server-product/conf/seata.yml">服务端的 seata.yml</tutorial-editor-open-file> 配置文件：
* 修改 `at>dsn` 数据库连接，无需密码 `root:@tcp(mysql:3306)/seata_order`
* 修改 `transaction_service_group` Seata 地址："127.0.0.1:8091"

**修改注册中心Nacos地址**
* 打开 <tutorial-editor-open-file filePath="/home/shell/shopping-order/go-server-product/conf/server.yml">服务端的 server.yml</tutorial-editor-open-file> 配置文件：
* 修改 `registries>nacos>address` Nacos 地址："127.0.0.1:65000"


### 修改 Client 配置

**修改Seata地址**
* 打开 <tutorial-editor-open-file filePath="/home/shell/shopping-order/go-client/conf/seata.yml">服务端的 seata.yml</tutorial-editor-open-file> 配置文件：
* 修改 `transaction_service_group` Seata 地址："127.0.0.1:8091"

**修改注册中心Nacos地址**
* 打开 <tutorial-editor-open-file filePath="/home/shell/shopping-order/go-client/conf/client.yml">服务端的 server.yml</tutorial-editor-open-file> 配置文件：
* 修改 `registries>nacos>address` Nacos 地址："127.0.0.1:65000"

## 运行程序

本节，你将使用 go 命令来运行上述的代码和配置

### 启动服务端

#### 启动 Order 服务端

1. 开启新 console 窗口执行 Order： <tutorial-terminal-open-tab name="Order服务端">点击我打开</tutorial-terminal-open-tab>

2. 在新窗口中执行命令，进入cmd目录，

```bash
cd shopping-order/go-server-order/cmd
```

指定配置文件, 启动服务端

```bash
export CONF_PROVIDER_FILE_PATH=../conf/server.yml && export SEATA_CONF_FILE=../conf/seata.yml && export GOPROXY=https://goproxy.io,direct && go run .
```

#### 启动 Product 服务端

1. 开启新 console 窗口执行 Product： <tutorial-terminal-open-tab name="Product服务端">点击我打开</tutorial-terminal-open-tab>

2. 在新窗口中执行命令，进入cmd目录，

```bash
cd shopping-order/go-server-product/cmd
```

3. 指定配置文件, 启动服务端(初次编译会1~2min)
```bash
export CONF_PROVIDER_FILE_PATH=../conf/server.yml && export SEATA_CONF_FILE=../conf/seata.yml && export GOPROXY=https://goproxy.io,direct && go run .
```


### 启动消费者并查看数据库

#### 说明
本示例为了演示分布式事务效果，可以通过与 `console` 输入指令进行交互，来查看 分布式事务正常提交 与 回滚 的直观效果。

- 默认 `debug` 模式：可通过 Console 交互，否则直接自动运行
- 两个演示模式: 
  - 正常提交模式 ： 根据 Console 提示，输入 `normal`，事务正常提交模式，可查看数据库效果
  - 正常提交模式 ： 根据 Console 提示，输入 `exception`，异常事务回滚模式，查看数据库回滚效果
    - 回滚模式下，分布式事务会经历`commit: insert data success -> rollback: data undo`过程，程序会自动在关键节点停顿，查看数据库验证效果后，请输入任意继续程序


#### 启动 Client

1. 开启新 console 窗口： <tutorial-terminal-open-tab name="Client">点击我打开</tutorial-terminal-open-tab>

2. 在新窗口中执行命令
```bash
cd shopping-order/go-client/cmd
```

3. 指定配置文件, 启动客户端
```bash
export CONF_CONSUMER_FILE_PATH=../conf/client.yml && export SEATA_CONF_FILE=../conf/seata.yml && export GOPROXY=https://goproxy.io,direct && go run .
```

#### 查看数据库记录

1. 开启新 console 窗口： <tutorial-terminal-open-tab name="Mysql">点击我打开</tutorial-terminal-open-tab>

2. 登录 Mysql 客户端查看记录

* 登录 Mysql 控制台：

```shell
mysql --defaults-file=/home/shell/.mysql/mysqld.cnf -uroot
```

* 查看下单记录
```mysql
use seata_order;
```
```mysql
select * from seata_order.so_master;
```
```mysql
select * from seata_order.so_item;
```

* 查看库存记录

```mysql
use seata_product;
```
```mysql
select * from seata_product.inventory;
```

---

Dubbo-go 在电商交易背景下分布式事务示例完成～

给个star鼓励一下我们吧： [github.com/apache/dubbo-go](https://github.com/apache/dubbo-go)

---

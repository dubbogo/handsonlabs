# 微服务开发入门教学

## 教程说明
通过该教程，你将会：
* 使用 dubbo-go 框架开启简单RPC服务
* 并完成客户端和服务端之间的调用示例。

案例学习时间预计5分钟左右。

## 准备工作
本节，你将通过 git 命令下载程序代码，并启动 Nacos 服务端

### 获取客户端程序代码
请使用下面的命令获取客户端及服务端程序代码
```bash
git clone github.com/dubbogo/handsonlabs -b helloworld-sourcecode
```

### 启动 Nacos 服务端
通过如下命令启动nacos服务端
```bash
sh ~/prepare.sh
```

----

通过如下命令观察nacos启动日志:
```bash
cat /home/shell/nacos/logs/start.out
```

待出现如下输出时，代表启动完成（如果未完成启动，可以重复执行上一条命令）:
> INFO Tomcat started on port(s): 65000 (http) with context path '/nacos'<br>
> ......<br>
> INFO Nacos started successfully in stand alone mode. use embedded storage




## 修改配置
本节，你讲修改代码的一些基本配置，让程序可以运行。<br>
请认真按照本节的引导操作。在完成修改后，一定要记得保存哦。

### 修改服务端配置

* 打开 <tutorial-editor-open-file filePath="/home/shell/go-server/conf/server.yml">服务端的 server.yml</tutorial-editor-open-file> 配置文件：

* 修改注册中心类型<br>
将 `protocol` 的值改为 `nacos`（<tutorial-editor-select-line startLine="14" filePath="/home/shell/go-server/conf/server.yml" replaceText="    protocol: 'nacos'">点我执行修改</tutorial-editor-select-line>）<br>

* 修改注册访问端口<br>
出于安全性和其他平台限制的考虑，目前外部只能使用6\[0-5\]000六个端口。
将 `address` 的端口改为 `65000`（<tutorial-editor-select-line startLine="16" filePath="/home/shell/go-server/conf/server.yml" replaceText="    address: '127.0.0.1:65000'">点我执行修改</tutorial-editor-select-line>）<br>


### 修改客户端配置

* 打开 <tutorial-editor-open-file filePath="/home/shell/go-client/conf/client.yml">客户端的 client.yml</tutorial-editor-open-file> 配置文件：

* 修改注册中心类型<br>
将 `protocol` 的值改为 `nacos`（<tutorial-editor-select-line startLine="20" filePath="/home/shell/go-client/conf/client.yml" replaceText="    protocol: 'nacos'">点我执行修改</tutorial-editor-select-line>）<br>

* 修改注册访问端口<br>
出于安全性和其他平台限制的考虑，目前外部只能使用6\[0-5\]000六个端口。
将 `address` 的端口改为 `65000`（<tutorial-editor-select-line startLine="22" filePath="/home/shell/go-client/conf/client.yml" replaceText="    address: '127.0.0.1:65000'">点我执行修改</tutorial-editor-select-line>）<br>


## 功能&代码说明

本节主要是对内容的说明和介绍，没有对项目的操作内容；

### 服务端
在本案例中，服务端只提供一个服务，即：
<tutorial-editor-open-file filePath="/home/shell/server/src/main/java/com/example/server/demos/nacosdiscoveryprovider/EchoServiceController.java">EchoServiceController</tutorial-editor-open-file> 
<br>
该服务只有一个方法，接收字符串型的消息，并返回 `"[ECHO] : " + message` 内容。这里的逻辑实现，并不具有太多的业务意义，只是对服务端逻辑执行的演示。

可以看到， 在 EchoServiceController 上增加了 `@RestController` 注解。熟悉 spring 的同学应该知道，这代表了被标注类是一个 Rest 风格的 http 接口。<br>
在 echo 方法上，由于标注了 `@GetMapping("/echo/{message}")` 注解，所以可以通过 `http://ip:port/echo/{message}` 来直接访问。<br>
其中的 \{message\} 可以被替换为你需要的任何消息。<br>
后面章节会对具体的访问做演示。


### 客户端
客户端程序自身并没有业务逻辑的实现，而是通过调用服务端的业务服务来实现业务，所以在本案例中需要重点关注如何使用客户端调用服务端。

在本案例中，客户端通过 nacos 的注册中心功能实现对服务端的发现。所以你会发现在客户端里并没有配置任何 `服务端的地址` 信息。<br>
参考：<tutorial-editor-open-file filePath="/home/shell/client/src/main/resources/application.properties">客户端的 application.properties</tutorial-editor-open-file>


本案例中的客户端通过两种方式调用服务端，所谓的”两种方式“具体来说是两种消费客户端的编程模型：
#### 使用 OpenFeign 方式<br>
参考：<tutorial-editor-open-file filePath="/home/shell/client/src/main/java/com/example/client/demos/nacosdiscoveryconsumer/OpenFeignController.java">OpenFeignController</tutorial-editor-open-file>，<tutorial-editor-open-file filePath="/home/shell/client/src/main/java/com/example/client/demos/nacosdiscoveryconsumer/EchoService.java">EchoService</tutorial-editor-open-file><br>

* `OpenFeignController` 作为web调用的入口，用于接收前端的调用请求，并向内调用业务与服务实现功能。<br>
* `EchoService` 是应用中对服务端所提供服务的引用接口。<br>
在这个接口上，标注了 `@FeignClient` 注解，以表示这个接口的服务是哪个服务端提供的。<br>
`@FeignClient` 注解的值代表了服务端应用的 `服务端应用名`，以便于在多个不同的服务提供者之间确定具体的服务。

####  使用 RestTemplate 方式<br>
参考：<tutorial-editor-open-file filePath="/home/shell/client/src/main/java/com/example/client/demos/nacosdiscoveryconsumer/RestTemplateController.java">RestTemplateController</tutorial-editor-open-file><br>
RestTemplate 是 spring 对所有 restful 服务调用的封装。<br>
在 RestTemplateController 中，通过 restTemplate.getForObject 来调用服务端的 EchoServiceController.echo 方法。<br>
通过前文的操作，将 getForObject 的第一个参数改为 `"http://server/echo/" + message`。这看起来像是一个标准的url地址，但是其中的`server`并不是域名，而是服务提供者的应用名。<br>

----
前文说到，客户端并不关注`服务端的地址`，但是需要关注`服务端应用名`，这两个概念是有区别的：
* `服务端应用名`：是一个逻辑概念，代表可以被独立部署的一套应用程序；
* `服务端的地址`：是物理概念，是实际部署以后具体的物理地址，例如IP；

每个`服务端应用名`可以部署多份实例，每个实例都有自己的`服务端的地址`。


## 运行程序

本节，你将使用 java 命令来运行上一步打包完成的 jar 文件

### 启动服务端
1. 开启新 console 窗口：<br>
<tutorial-terminal-open-tab name="服务端">点击我打开</tutorial-terminal-open-tab>

2. 在新窗口中执行命令
```bash
cd go-server/cmd
export CONF_PROVIDER_FILE_PATH=../conf/server.yml
go run .
```
看到下面的反馈则表示启动成功<br>


### 启动客户端
1. 开启新 console 窗口：<br>
<tutorial-terminal-open-tab name="客户端">点击我打开</tutorial-terminal-open-tab>

2. 在新窗口中执行命令
```bash
cd go-client/cmd
export CONF_CONSUMER_FILE_PATH=../conf/client.yml
go run .
```
看到下面的反馈则表示启动成功<br>
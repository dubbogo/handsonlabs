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
git clone https://code.aliyun.com/handsonlabs/dubbo-go.git -b helloworld
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

* 打开 <tutorial-editor-open-file filePath="/home/shell/dubbo-go/go-server/conf/server.yml">服务端的 server.yml</tutorial-editor-open-file> 配置文件：

* 修改注册中心类型<br>
将 `protocol` 的值改为 `nacos`（<tutorial-editor-select-line startLine="14" startCharacterOffset="5" filePath="/home/shell/dubbo-go/go-server/conf/server.yml" replaceText='protocol: "nacos"'>点我执行修改</tutorial-editor-select-line>）<br>

* 修改注册访问端口<br>
出于安全性和其他平台限制的考虑，目前外部只能使用6\[0-5\]000六个端口。
将 `address` 的端口改为 `65000`（<tutorial-editor-select-line startLine="16" startCharacterOffset="5" filePath="/home/shell/dubbo-go/go-server/conf/server.yml" replaceText='address: "127.0.0.1:65000"'>点我执行修改</tutorial-editor-select-line>）<br>

### 修改客户端配置

* 打开 <tutorial-editor-open-file filePath="/home/shell/dubbo-go/go-client/conf/client.yml">客户端的 client.yml</tutorial-editor-open-file> 配置文件：

* 修改注册中心类型<br>
将 `protocol` 的值改为 `nacos`（<tutorial-editor-select-line startLine="20" startCharacterOffset="5"  filePath="/home/shell/dubbo-go/go-client/conf/client.yml" replaceText='protocol: "nacos"'>点我执行修改</tutorial-editor-select-line>）<br>


* 修改注册访问端口<br>
出于安全性和其他平台限制的考虑，目前外部只能使用6\[0-5\]000六个端口。
将 `address` 的端口改为 `65000`（<tutorial-editor-select-line startLine="22" startCharacterOffset="5"  filePath="/home/shell/dubbo-go/go-client/conf/client.yml" replaceText='address: "127.0.0.1:65000"'>点我执行修改</tutorial-editor-select-line>）<br>


## 修改代码依赖
本节，你讲修改代码的注册引用依赖，导入nacos的注册pkg。<br>	

由于需要使用nacos作为注册中心，需要import nacos依赖到代码中，方可使用\

请认真按照本节的引导操作。在完成修改后，一定要记得保存哦。
### 修改客户端代码依赖
* 打开 <tutorial-editor-open-file filePath="/home/shell/dubbo-go/go-client/cmd/client.go">客户端的 client.go</tutorial-editor-open-file> 源码：
* 修改客户端nacos注册pkg依赖包
将默认 `zookeeper` 的值改为 `nacos`（<tutorial-editor-select-line startLine="40" filePath="/home/shell/dubbo-go/go-client/cmd/client.go" replaceText='\t_ "github.com/apache/dubbo-go/registry/nacos"'>点我执行修改</tutorial-editor-select-line>）<br>

### 修改服务端代码依赖
* 打开 <tutorial-editor-open-file filePath="/home/shell/dubbo-go/go-server/cmd/server.go">服务端的 server.go</tutorial-editor-open-file> 源码：
* 修改服务端nacos注册pkg依赖包
将默认 `zookeeper` 的值改为 `nacos`（<tutorial-editor-select-line startLine="37" filePath="/home/shell/dubbo-go/go-server/cmd/server.go" replaceText='\t_ "github.com/apache/dubbo-go/registry/nacos"'>点我执行修改</tutorial-editor-select-line>）<br>



## 功能&代码说明

本节主要是对内容的说明和介绍，没有对项目的操作内容；

### 服务端
在本案例中，服务端只提供一个服务，即：
* 打开 <tutorial-editor-open-file filePath="/home/shell/dubbo-go/go-server/pkg/user.go">服务端的 user.go</tutorial-editor-open-file> 源码：

该服务Provider只有一个方法，接收字符串消息，返回定义好并且注册在hessian2上的User结构体。
```go
type UserProvider struct {
}

func (u *UserProvider) GetUser(ctx context.Context, req []interface{}) (*User, error) {
	gxlog.CInfo("req:%#v", req)
	rsp := User{"A001", "Alex Stocks", 18, time.Now()}
	gxlog.CInfo("rsp:%#v", rsp)
	return &rsp, nil
}
```
在当前文件init函数中，将当前服务注册注册在了框架配置上。

并且将自定义参数注册在hessian2上
```go
func init() {
	config.SetProviderService(new(UserProvider))
	// ------for hessian2------
	hessian.RegisterPOJO(&User{})
}

```

对于User结构体，需要实现JavaClassName作为go与java数据传输的媒介,用于hessian2注册。

Reference返回的字符串，与配置中指定的service Key 相对应

* 打开 <tutorial-editor-select-line startLine="20"  filePath="/home/shell/dubbo-go/go-server/conf/server.yml">服务端配置 server.yml</tutorial-editor-select-line>

框架会根据当前service Key下的配置，暴露指定Provider
```go
func (u *UserProvider) Reference() string {
	return "UserProvider"
}

func (u User) JavaClassName() string {
	return "org.apache.dubbo.User"
}
```

* 打开 <tutorial-editor-open-file filePath="/home/shell/dubbo-go/go-server/cmd/server.go">服务端的 server.go</tutorial-editor-open-file> 源码：
可见调用config.Load，启动框架，之后开启信号监听。
```go
func main() {
	config.Load()

	initSignal()
}
```


### 客户端
* 打开 <tutorial-editor-open-file filePath="/home/shell/dubbo-go/go-client/pkg/user.go">客户端的 user.go</tutorial-editor-open-file> 源码：
可以看到类似的引用结构定义，其中Reference()返回reference key与配置相对应： <tutorial-editor-select-line startLine="28"  filePath="/home/shell/dubbo-go/go-client/conf/client.yml">客户端配置 client.yml</tutorial-editor-select-line>
```go
type User struct {
	Id   string
	Name string
	Age  int32
	Time time.Time
}

type UserProvider struct {
	GetUser func(ctx context.Context, req []interface{}, rsp *User) error
}

func (u *UserProvider) Reference() string {
	return "UserProvider"
}

func (User) JavaClassName() string {
	return "org.apache.dubbo.User"
}
```

* 打开 <tutorial-editor-select-line startLine="48"  filePath="/home/shell/dubbo-go/go-client/cmd/client.go">客户端配置 client.go</tutorial-editor-select-line>

在client.go调用方法之前，新建Provider实例，并注册在框架上

传输结构体也需要注册在hessian2上进行打解包
```go
var userProvider = new(pkg.UserProvider)

func init() {
	config.SetConsumerService(userProvider)
	hessian.RegisterPOJO(&pkg.User{})
}
```


## 运行程序

本节，你将使用 go 命令来运行上述的代码和配置

### 启动服务端
1. 开启新 console 窗口：<br>
<tutorial-terminal-open-tab name="服务端">点击我打开</tutorial-terminal-open-tab>

2. 在新窗口中执行命令\
进入cmd目录
```bash
cd dubbo-go/go-server/cmd
```

指定配置文件, 启动服务端
```bash
export CONF_PROVIDER_FILE_PATH=../conf/server.yml
go run .
```

看到下面的反馈则表示启动成功<br>
```
 nacos/registry.go:200   update begin, service event: ServiceEvent{Action{add}, Path{dubbo...
```


### 启动客户端
1. 开启新 console 窗口：<br>
<tutorial-terminal-open-tab name="客户端">点击我打开</tutorial-terminal-open-tab>

2. 在新窗口中执行命令
```bash
cd dubbo-go/go-client/cmd
```


指定配置文件, 启动服务端
```bash
export CONF_CONSUMER_FILE_PATH=../conf/client.yml
go run .
```

看到下面的反馈则表示调用成功<br>
```
[2021-03-04/05:53:34 main.main: client.go: 64] response result: &{A001 Alex Stocks 18 2021-03-04 05:53:34.253 +0000 UTC}
```
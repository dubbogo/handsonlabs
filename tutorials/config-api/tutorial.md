# Dubbogo config-api 简单应用案例

## 教程说明
通过该教程，你将会：
* 使用 dubbo-go 的配置API开启简单RPC服务
* 完成客户端和服务端之间的调用示例。

案例学习时间预计15分钟左右。

点击右下角的"下一步"按钮继续。

## 准备工作
本节，你将通过 git 命令下载程序代码，并启动 Nacos 服务端

### 获取客户端及服务端程序代码
请使用下面的命令获取客户端及服务端程序代码
```bash
git clone https://github.com/Suiruibin/handsonlabs-sample.git
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

待出现``如下输出时，代表启动完成（如果未完成启动，可以重复执行上一条命令）:
> INFO Tomcat started on port(s): 65000 (http) with context path '/nacos'<br>
> ......<br>
> INFO Nacos started successfully in stand alone mode. use embedded storage



## 功能&代码说明

本节主要是对内容的说明和介绍，没有对项目的操作内容；

### 服务端
在本案例中，服务端只提供一个服务，即：
* 打开 <tutorial-editor-open-file filePath="/home/shell/handsonlabs-sample/config-api/go-server/pkg/user.go">服务端的 user.go</tutorial-editor-open-file> 源码：

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
对于User结构体，需要实现JavaClassName作为go与java数据传输的媒介,用于hessian2注册

Reference返回的字符串，与配置中指定的service Key 相对应

框架会根据当前service Key下的配置，暴露指定Provider
```go
func (u *UserProvider) Reference() string {
	return "UserProvider"
}

func (u User) JavaClassName() string {
	return "org.apache.dubbo.User"
}
```
* 打开 <tutorial-editor-open-file filePath="/home/shell/handsonlabs-sample/config-api/go-server/cmd/server.go">服务端的 server.go</tutorial-editor-open-file> 源码：

在当前文件setConfigByAPI函数中，利用dubbo-go提供的API设置服务提供者的配置参数，你不需要在环境变量中定义服务端配置文件的位置
```go
func setConfigByAPI() {
    providerConfig := config.NewProviderConfig(
        config.WithProviderAppConfig(config.NewDefaultApplicationConfig()),// 默认app配置
        config.WithProviderProtocol("dubbo", "dubbo", "20000"),// 协议key、协议名和端口号
        config.WithProviderRegistry("demoZk", config.NewDefaultRegistryConfig("zookeeper")),// 注册中心配置
        config.WithProviderServices("UserProvider", config.NewServiceConfigByAPI(
            config.WithServiceRegistry("demoZk"),// 注册中心 key, 和上面注册中心key保持一致
            config.WithServiceProtocol("dubbo"), // 暴露协议，和上面协议key对应
            config.WithServiceInterface("org.apache.dubbo.UserProvider"),// interface id
            config.WithServiceLoadBalance("random"),// 负载均衡
            config.WithServiceWarmUpTime("100"),
            config.WithServiceCluster("failover"),
            config.WithServiceMethod("GetUser", "1", "random"),
        )),
    )   
    config.SetProviderConfig(*providerConfig)// 写入providerConfig指针
}
```
在main函数中，可见调用config.Load，启动框架，之后开启信号监听。
```go
func main() {
	hessian.RegisterPOJO(&pkg.User{})
	config.Load()

	initSignal()
}
```


### 客户端
* 打开 <tutorial-editor-open-file filePath="/home/shell/handsonlabs-sample/config-api/go-client/pkg/user.go">客户端的 user.go</tutorial-editor-open-file> 源码：
可以看到类似的引用结构定义，其中Reference()返回reference key与配置相对应：
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

* 打开 <tutorial-editor-open-file filePath="/home/shell/handsonlabs-sample/config-api/go-client/cmd/client.go">客户端的 client.go</tutorial-editor-open-file> 

在当前文件setConfigByAPI函数中，利用dubbo-go提供的API设置服务消费者的配置参数，你不需要在环境变量中定义客户端配置文件的位置
```go
func setConfigByAPI() {
    consumerConfig := config.NewConsumerConfig(
        config.WithConsumerAppConfig(config.NewDefaultApplicationConfig()), // 默认app配置
        config.WithConsumerConnTimeout(time.Second*3), // timeout
        config.WithConsumerRequestTimeout(time.Second*3), // timeout
        config.WithConsumerRegistryConfig("demoZk", config.NewDefaultRegistryConfig("zookeeper")), // 注册中心配置
        config.WithConsumerReferenceConfig("UserProvider", config.NewReferenceConfigByAPI( // set refer config
            config.WithReferenceRegistry("demoZk"), // registry key
            config.WithReferenceProtocol("dubbo"), // protocol 
            config.WithReferenceInterface("org.apache.dubbo.UserProvider"),// interface name
            config.WithReferenceMethod("GetUser", "3", "random"), // method and lb
            config.WithReferenceCluster("failover"),
        )),
    )
    config.SetConsumerConfig(*consumerConfig) // 写入 consumerConfig 指针
}
```

在client.go调用方法之前，调用参数配置函数，调用新建Provider实例，并注册在框架上

传输结构体也需要注册在hessian2上进行打解包
```go
var userProvider = new(pkg.UserProvider)

func init() {
    setConfigByAPI()
    config.SetConsumerService(userProvider)
	hessian.RegisterPOJO(&pkg.User{})
}
```
## 修改配置
本节，你将修改代码的一些基本配置，让程序可以运行。<br>
请认真按照本节的引导操作。在完成修改后，一定要记得保存哦。

### 修改服务端配置

* 打开 <tutorial-editor-open-file filePath="/home/shell/handsonlabs-sample/config-api/go-server/cmd/server.go">服务端的 server.go</tutorial-editor-open-file> 源码：

* 修改注册中心类型及端口<br>
  将zookeeper注册中心改为Nacos注册中心，并出于安全性和其他平台限制的考虑，注册端口改为65000（<tutorial-editor-select-line startLine="53" startCharacterOffset="41" filePath="/home/shell/handsonlabs-sample/config-api/go-server/cmd/server.go" replaceText='config.NewRegistryConfig(config.WithRegistryProtocol("nacos"),config.WithRegistryAddress("127.0.0.1:65000"),config.WithRegistryTimeOut("3s"))),'>点我执行修改</tutorial-editor-select-line>）<br>
  
* 修改dubbogo服务监听端口<br>
  出于安全性和其他平台限制的考虑，目前外部只能使用6\[0-5\]000六个端口。
  将 `dubbo` 的端口改为 `60000`（<tutorial-editor-select-line startLine="52" startCharacterOffset="49"  filePath="/home/shell/handsonlabs-sample/config-api/go-server/cmd/server.go" replaceText='"60000"),'>点我执行修改</tutorial-editor-select-line>）<br>

### 修改客户端配置

* 打开 <tutorial-editor-open-file filePath="/home/shell/handsonlabs-sample/config-api/go-client/cmd/client.go">客户端的 client.go</tutorial-editor-open-file> 源码：

* 修改注册中心类型及端口<br>
  将zookeeper注册中心改为Nacos注册中心，并出于安全性和其他平台限制的考虑，注册端口改为65000（<tutorial-editor-select-line startLine="50" startCharacterOffset="46" filePath="/home/shell/handsonlabs-sample/config-api/go-client/cmd/client.go" replaceText='config.NewRegistryConfig(config.WithRegistryProtocol("nacos"),config.WithRegistryAddress("127.0.0.1:65000"),config.WithRegistryTimeOut("3s"))),'>点我执行修改</tutorial-editor-select-line>）<br>

  
## 修改代码依赖
本节，你将修改代码的注册引用依赖，导入nacos的注册pkg。<br>

由于需要使用nacos作为注册中心，需要import nacos依赖到代码中，方可使用

请认真按照本节的引导操作。在完成修改后，一定要记得保存哦。
### 修改客户端代码依赖
* 打开 <tutorial-editor-open-file filePath="/home/shell/handsonlabs-sample/config-api/go-client/cmd/client.go">客户端的 client.go</tutorial-editor-open-file> 源码：
* 修改客户端nacos注册pkg依赖包
  将默认 `zookeeper` 的值改为 `nacos`（<tutorial-editor-select-line startLine="35" filePath="/home/shell/handsonlabs-sample/config-api/go-client/cmd/client.go" replaceText='\t_ "github.com/apache/dubbo-go/registry/nacos"'>点我执行修改</tutorial-editor-select-line>）<br>

### 修改服务端代码依赖
* 打开 <tutorial-editor-open-file filePath="/home/shell/handsonlabs-sample/config-api/go-server/cmd/server.go">服务端的 server.go</tutorial-editor-open-file> 源码：
* 修改服务端nacos注册pkg依赖包
  将默认 `zookeeper` 的值改为 `nacos`（<tutorial-editor-select-line startLine="38" filePath="/home/shell/handsonlabs-sample/config-api/go-server/cmd/server.go" replaceText='\t_ "github.com/apache/dubbo-go/registry/nacos"'>点我执行修改</tutorial-editor-select-line>）<br>





## 运行程序

本节，你将使用 go 命令来运行上述的代码和配置

### 启动服务端
1. 开启新 console 窗口：<br>
<tutorial-terminal-open-tab name="服务端">点击我打开</tutorial-terminal-open-tab>

2. 在新窗口中执行命令，进入cmd目录
```bash
cd handsonlabs-sample/config-api/go-server/cmd
```

启动服务端
```bash
export GOPROXY=https://goproxy.io,direct && go run .
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
cd handsonlabs-sample/config-api/go-client/cmd
```


启动客户端
```bash
export GOPROXY=https://goproxy.io,direct && go run .
```

看到下面的反馈则表示调用成功<br>
```
[2021-04-19/05:53:34 main.main: client.go: 64] response result: &{A001 Alex Stocks 18 2021-04-19 05:53:34.253 +0000 UTC}
```

dubbo-go的config-api功能体验完成～

给个star鼓励一下我们吧： [github.com/apache/dubbo-go](https://github.com/apache/dubbo-go)
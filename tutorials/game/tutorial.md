# Dubbogo game 足球游戏案例

## 教程说明

通过该教程，你将会：
* 使用 dubbo-go 构建一个简单的服务端
* 了解 vue.js 框架的使用

案例学习时间预计15分钟左右。

## 准备工作

本节，你将通过 git 命令下载程序代码，并启动 Nacos 服务端

### 获取前端及服务端代码

请使用下面的命令获取客户端及服务端程序代码
```bash
git clone https://github.com/cjphaha/handsonlabs-samples.git
```

### 启动 Nacos 服务端

通过如下命令启动 nacos 服务端
```bash
sh ~/prepare.sh
```

----

通过如下命令观察 nacos 启动日志:
```bash
cat /home/shell/nacos/logs/start.out
```

待出现如下输出时，代表启动完成（如果未完成启动，可以重复执行上一条命令）:
> INFO Tomcat started on port(s): 65000 (http) with context path '/nacos'<br>
> ......<br>
> INFO Nacos started successfully in stand alone mode. use embedded storage

## 功能 & 代码说明

本节主要是对内容的说明和介绍，没有对项目的操作内容；

### 服务端

#### 背景介绍

- 示例包含 **gate** (网关服务) 和 **game** (逻辑服务) 两个服务
- 两个服务会互相 RPC 通讯 (都同时注册 **provider** 和 **consumer**)
- **gate** 额外启动了 http 服务 (端口 **8000**), 用于手工触发  **gate** RPC 调用 **game**

> 每次 **gate** RPC调用 (**Message**) **game** 后, **game** 会同步RPC调用(Send) **gate** 推送相同消息

#### 概要

目录说明

```bash
├── go-server-game    # game 模块
│   ├── cmd           # 主入口
│   ├── conf          # 配置文件
│   ├── docker        # docker-compose 文件
│   ├── pkg           # provider 和 consumer
│   └── tests
├── go-server-gate    # gate 模块
│   ├── cmd           # 主入口
│   ├── conf          # 配置文件
│   ├── docker        # docker-compose文件
│   ├── pkg           # provider 和 consumer
│   └── tests
└── pkg
    ├── consumer      # 公共 consumer
    │   ├── game
    │   └── gate
    └── pojo
```

发起 http 服务的流程

<img src="http://cdn.cjpa.top/cdnimages/image-20210423212453935.png" alt="image-20210423212453935" style="zoom:50%;" />



从 consumer 和 provider 角度来看，发起一次调用的流程是这样的

<img src="http://cdn.cjpa.top/cdnimages/image-20210424094134541.png" alt="image-20210424094134541" style="zoom: 33%;" />

game 提供了 basketball 服务端，gate提供了http服务端。

#### game 模块

##### server 端

server 端提供三个服务，Login、Score 及 Rank，代码如下，具体的实现可以在 game/go-server-game/pkg/provider.go 中看到

```go
type BasketballService struct{}

func Login(ctx context.Context, data string) (*pojo.Result, error) {
    ...
}

func Score(ctx context.Context, uid, score string) (*pojo.Result, error) {
    ...
}

func Rank (ctx context.Context, uid string) (*pojo.Result, error) {
    ...
}

func (p *BasketballService) Reference() string {
    return "gameProvider.basketballService"
}
```

##### 配置文件

 在配置文件中注册 service，其中 gameProvider.basketballService 和 Reference 方法中声明的一致。

```yml
services:
  "gameProvider.basketballService":
    registry: "demoZk"
    protocol: "dubbo"
    interface: "org.apache.dubbo.game.BasketballService"
    loadbalance: "random"
    warmup: "100"
    cluster: "failover"
    methods:
      - name: "Online"
        retries: 0
      - name: "Offline"
        retries: 0
      - name: "Message"
        retries: 
```

##### consumer端

basketball 部分的 consumer 主要用来被 gate 调用，因此主要代码放在了  game/pkg/consumer/gate/basketball.go中，这部分作为公共部分，consumer 代码如下

```go
type BasketballService struct {
    Send func(ctx context.Context, uid string, data string) (*pojo.Result, error)
}

func (p *BasketballService) Reference() string {
    return "gateConsumer.basketballService"
}
```

在 basketball 中，只需要实例化一个 consumer 变量即可

```go
var gateBasketball = new(gate.BasketballService)
```

然后在main中注册到dubbo-go

```go
config.SetConsumerService(gateBasketball)
```

##### 配置文件

```yml
references:
  "gateConsumer.basketballService":
    registry: "demoZk"
    protocol : "dubbo"
    interface : "org.apache.dubbo.gate.BasketballService"
    cluster: "failover"
    methods:
      - name: "Send"
        retries: 0
```

由于 game 的 consumer 需要调用 gate 的 provider，因此 Reference 方法返回的字符串为 gateConsumer.basketballService ，在配置文件中 gateConsumer.basketballService 和 game/pkg/consumer/gate/basketball.go 中Reference 方法声明的一致，intreface 的值也要和 gate 的 provider 设置的一致。

#### gate 模块

##### server 端

```go
type BasketballService struct{}

func (p *BasketballService) Send(ctx context.Context, uid, data string) (*pojo.Result, error) {
...
}

func (p *BasketballService) Reference() string {
    return "gateProvider.basketballService"
}
```

注册到 dubbo

```go
config.SetProviderService(new(BasketballService))
```

##### http 服务

gate 模块提供了 http 服务，默认监听 60000 端口，用来部署前端项目及接收前端的 http 请求，这部分的实现如下所示

```go
func startHttp() {
  	// 登陆
    http.HandleFunc("/login", func(w http.ResponseWriter, r *http.Request) {})
  	// 得分
    http.HandleFunc("/score", func(w http.ResponseWriter, r *http.Request) {})
  	// 排名
    http.HandleFunc("/rank", func(w http.ResponseWriter, r *http.Request) {})
  	// 文件服务
    http.Handle("/", http.FileServer(http.Dir("../../website/")))
    _ = http.ListenAndServe("0.0.0.0:60000", nil)
}
```

##### 配置文件

gateProvider.basketballService 和 Reference 中的一致，这里的 interface 一定要和 game 的 client.yml 文件中设置的保持一致，不然 game 无法向 gate 发送数据

```yml
# service config
services:
  "gateProvider.basketballService":
    registry: "demoZk"
    protocol : "dubbo"
    interface : "org.apache.dubbo.gate.BasketballService"
    loadbalance: "random"
    warmup: "100"
    cluster: "failover"
    methods:
      - name: "Send"
        retries: 0
```

##### consumer 端

gate 中的 consumer 端比较特殊，由于 gate的consumer 需要调用 game 中的 service，所以在 gate 中，consumer 直接实例化一个 game 的 service，其方法便直接使用实例化的对象 GameBasketball 调用，这样就实现了一个网关的功能。

```go
var GameBasketball = new(game.BasketballService)

func Login(ctx context.Context, data string) (*pojo.Result, error) {
    return GameBasketball.Login(ctx, data)
}

func Score(ctx context.Context, uid, score string) (*pojo.Result, error) {
    return GameBasketball.Score(ctx, uid, score)
}

func Rank (ctx context.Context, uid string) (*pojo.Result, error) {
    return GameBasketball.Rank(ctx, uid)
}
```

代码中的 GameBasketball.Message、GameBasketball.Online、GameBasketball.Offline 调用的方法都是 game 的方法

注册到 dubbo

```go
config.SetProviderService(new(pkg.BasketballService))
```

##### 配置文件

配置文件中的 interface 也要和 game 的 provider 保持一致，不然收到 http 请求之后无法调用 gate

```yml
references:
  "gameConsumer.basketballService":
    registry: "demoZk"
    protocol : "dubbo"
    interface : "org.apache.dubbo.game.BasketballService"
    cluster: "failover"
    methods:
      - name: "Online"
        retries: 0
      - name: "Offline"
        retries: 0
      - name: "Message"
        retries: 0
```

### 前端

前端使用 vue.js 框架 + JQuery.js 框架 + element-ui 样式库，其中 vue.js 框架承担了大多数功能，http 服务借助jQuery 框架提供的 ajax，弹窗使用了element-ui 的 dialog 组件

#### 项目结构

```bash
├── css
│   └── style.css		# 足球、小人的样式
├── img							# 背景图
├── index.html			# 首页
└── js
    ├── api.js			# 接口
    └── index.js		# 主逻辑
```



在使用之前，应在 index.html 中导入相应的框架

```html
<!-- jquery框架 -->
<script src="https://apps.bdimg.com/libs/jquery/2.1.4/jquery.min.js"></script>
<!-- vue框架 -->
<script src="https://unpkg.com/vue/dist/vue.js"></script>
<!-- element-ui样式 -->
<link rel="stylesheet" href="https://unpkg.com/element-ui/lib/theme-chalk/index.css">
<!-- element-ui组件库 -->
<script src="https://unpkg.com/element-ui/lib/index.js"></script>
```

#### 接口

前端向后后端发送 GET/POST 请求使用的是 ajax，如下是登录接口的代码

```javascript
var baseURL = window.document.location.href

function login(data) {
    return new Promise(function(resolve, reject) {
        $.ajax({
            type: "get",
            url: baseURL + 'login',
            data:data,
            dataType: "json", //指定服务器返回的数据类型
            success: function (response) {
                if (response.code != 0) {
                    reject(response.msg)
                } else {
                    resolve(response)
                }
            },
            error:function(err){
                reject(err)
            }
        });
    })
}
```

由于外部设备想要访问知行实验室需要通过知行实验室制定的代理地址，因此前端需要在页面加载的时候获取当前服务的 url，这部分的代码如下所示

```javascript
var baseURL = window.document.location.href
```

#### 球门移动逻辑

```javascript
move: function () {
            var elem = document.getElementById("myBar")
            var width = 0
            var id = setInterval(frame, 20)
            function frame() {
                if (width >= 100) {
                    clearInterval(id)
                    elem.remove()
                } else {
                    width++
                    elem.style.width = width + '%'
                    elem.innerHTML = width * 1 + '%'
                }
            }
            
        }
```

#### 射球逻辑

```javascript
 moveBall:function(){
            var elem = document.getElementsByClassName("ball")
            var gate = document.getElementById("gate")
            var id = setInterval(frame, 20)
            var tempHeight = 0
            var that = this
            function frame() {
                var space = elem[0].getBoundingClientRect().left - gate.getBoundingClientRect().left
                var hight = elem[0].getBoundingClientRect().top - gate.getBoundingClientRect().top
                if (!that.isMeet && (space <60 && space > -20 && hight < 20 && hight > -20)) {
                    that.isMeet = true
                    score(JSON.stringify({name:that.info.name, score:1})).then(Response => {
                        that.info.score = Response.data.score
                        that.$message({
                            message:"进球成功, 总分数为:" + Response.data.score,
                            type:"success"
                        })
                        that.getRank()
                    }).catch( e => {
                        that.$message({
                            message: "分数统计失败" + e,
                            type:"danger"
                        })
                    })
                }
                if (tempHeight >= that.clientHeight) {
                    elem[0].style.bottom = 0 + ''
                    clearInterval(id)
                } else{
                    tempHeight += 20
                    elem[0].style.bottom = tempHeight + ''
                }
            }
        }
```

## 运行程序
### 启动服务端
#### 启动 game
1. 开启新 console 窗口：<br>
<tutorial-terminal-open-tab name="服务端">点击我打开</tutorial-terminal-open-tab>

2. 在新窗口中执行命令，进入 cmd 目录
```bash
cd handsonlabs-samples/game/go-server-game/cmd
```

指定配置文件, 启动服务端
```bash
export CONF_PROVIDER_FILE_PATH=../conf/server.yml && 
export CONF_CONSUMER_FILE_PATH=../conf/client.yml && 
export GOPROXY=https://goproxy.io,direct && 
go run .
```

看到下面的反馈则表示启动成功<br>
```bash
nacos/registry.go:200   update begin, service event: ServiceEvent{Action{add}, Path{dubbo...
```
#### 启动 gate
1. 开启新 console 窗口：<br>
<tutorial-terminal-open-tab name="服务端">点击我打开</tutorial-terminal-open-tab>

2. 在新窗口中执行命令，进入 cmd 目录
```bash
cd handsonlabs-samples/game/go-server-gate/cmd
```

指定配置文件, 启动服务端
```bash
export CONF_PROVIDER_FILE_PATH=../conf/server.yml && 
export CONF_CONSUMER_FILE_PATH=../conf/client.yml && 
export GOPROXY=https://goproxy.io,direct && 
go run .
```

看到下面的反馈则表示启动成功<br>
```bash
nacos/registry.go:200   update begin, service event: ServiceEvent{Action{add}, Path{dubbo...
```

### 启动前端

由于 gate 端已经对前端进行了部署，访问 60000 端口便会收到 gate 端从 website 文件夹中读取到的 HTML、JavaScript 及 CSS 内容，知行实验室提供了部分预览端口，如果需要外部访问在右上角点击 60000 即可访问

![image-20210529201752331](http://cdn.cjpa.top/image-20210529201752331.png)



打开后可以看到如下的界面

![image-20210530200815948](http://cdn.cjpa.top/cdnimages/image-20210530200815948.png)
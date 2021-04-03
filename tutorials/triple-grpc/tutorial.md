# dubbo3 grpc

## 教程说明

通过本教程，你将会

* 使用dubbo-go3.0开启简单的RPC服务
* 完成客户端和服务端之间的调用实例

## 准备工作

本节你将通过过git命令下载代码，并启动zookeeper注册中心

### 获取客户端及服务端代码

请使用下面的命令获取客户端及服务端代码

```bash
git clone https://github.com/cjphaha/handsonlabs-samples.git
cd triple-grpc
```

### 启动zookeeper

通过如下命令启动zookeeper

```bash
sh ~/prepare.sh
```

## 功能&代码说明

### proto

grpc通信需要通过在服务端和客户端之间定一个同一个protobuf文件，然后使用protoc工具打包出对应语言的pb.go文件。

本案例中直接运行protobuf/protobuf.mk会自动安装protoc-gen-go以及protoc-gen-dubbo3拓展，生成pb.go相应的文件。

该proto文件声明了rpc调用和返回数据的字段，以及rpc方法。

```protobuf
syntax = "proto3";

package protobuf;

service Dubbo3Greeter {
  rpc Dubbo3Hello(Dubbo3HelloRequest) returns (Dubbo3HelloReply) {}
}

message Dubbo3HelloRequest {
  string req = 1;
}

message Dubbo3HelloReply {
  string rsp = 1;
}

```

### 服务端

本案例中服务端提供了一个服务即

```go
type GreeterProvider struct {
	*pb.Dubbo3GreeterProviderBase
}
```

其中Dubbo3GreeterProviderBase是编码protobuf文件时生成的，无需改动。



该服务只有一个方法Dubbo3Hello，该服务接收客户端的的消息，并在相应的消息体前加上hello。

```go
func (g *GreeterProvider) Dubbo3Hello(ctx context.Context, in *pb.Dubbo3HelloRequest) (*pb.Dubbo3HelloReply, error) {
	// 这里打印的是协议头的字段 
    fmt.Println("######### get server request data :" + in.Req)
	fmt.Println("get tri-req-id = ", ctx.Value("tri-req-id"))
	return &pb.Dubbo3HelloReply{Rsp: "Hello " + in.Req}, nil
}
```



Reference返回的字符串，与配置中指定的service Key 相对应，框架会根据当前service Key的值，暴露指定Provider

```go
func (g *GreeterProvider) Reference() string {
	return "GrpcGreeterImpl"
}
```



由于使用了tripe协议，在main包中需要导入dubbo3包

```go
import (
  _ "github.com/apache/dubbo-go/protocol/dubbo3"
)
```



server端运行时将provider注册到dubbo，并监听信号

```bash
func main() {
	config.SetProviderService(pkg.NewGreeterProvider())
	config.Load()
	initSignal()
}
```

### 客户端

同客户端一样，客户端也需要有Reference()函数

```bash
func (u *GrpcGreeterConsumer) Reference() string {
	return "GrpcGreeterImpl"
}
```



在consummer结构体中需要声明调用的方法，该方法与服务端有一些不同

```go
type GrpcGreeterConsumer struct {
	Dubbo3Hello func(ctx context.Context, in *pb.Dubbo3HelloRequest, out *pb.Dubbo3HelloReply) error
}
```



dubbo3客户端

```go
func (u *GrpcGreeterConsumer) GetDubboStub(tc *dubbo3.TripleConn) pb.Dubbo3GreeterClient {
	return pb.NewDubbo3GreeterDubbo3Client(tc)
}
```



main包中导入dubbo3

```go
import (
  _ "github.com/apache/dubbo-go/protocol/dubbo3"
)
```



将consumer注册到dubbo，然后倒入配置，监听信号

```go
var GrpcGreeterConsumer = new(pkg.GrpcGreeterConsumer)

func main( )  {
	config.SetConsumerService(GrpcGreeterConsumer)
	config.Load()
	test()
}
```



发起grpc调用

```go
func test(){
	in := &pb.Dubbo3HelloRequest{
		Req: "cjp",
	}
	out := &pb.Dubbo3HelloReply{}
	err := grpcGreeterImpl.Dubbo3Hello(context.Background(), in, out)
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(out)
}
```

## 运行程序

本节，你将使用命令来启动服务端和客户端完成一次基于dubbo3.0的grpc调用

### 启动服务端

配置路径

```bash
export CONF_PROVIDER_FILE_PATH=./conf/server.yml
export APP_LOG_CONF_FILE=./conf/log.yml
```

启动

```bash
go run .
```

### 启动客户端

配置路径

```bash
export CONF_CONSUMER_FILE_PATH=./conf/client.yml
export APP_LOG_CONF_FILE=./conf/log.yml
```

启动

```bash
go run .
```

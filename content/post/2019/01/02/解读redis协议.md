---
title: "解读redis协议"
date: 2019-01-02T17:20:16+08:00
tags: ["Redis", "协议"]
categories: ["Redis"]
draft: false
---

## 前言
Redis作为我们日常使用的key-value数据库，不光操作简单(例如`set get delete`等指令)，通信协议也简洁明了。
本篇就会剖析Redis的通信协议，并且实现一个简单的Redis客户端。

## 协议
Redis服务端与客户端使用的基于TCP的文本协议(敲黑板，这里并没有使用效率更高的二进制协议)，称之为`RESP`(Redis Serialization Protocol)。区别于同样是文本协议的`HTTP`协议，`RESP`尤为简洁，其基础规则很容易理解。

### 请求信息
假如我们执行`set test ok`这样的命令，可以视为准备了一个`["set", "test", "ok"]`这样的数组，随即将其序列化为字符串，序列化规则如下:

+ 首先以每一个指令以`*`开头指明数组长度
+ 以`$`开头指明下个元素的字符长度
+ 每一个元素以间隔符号`\r\n`(CRLF)隔开

按这个规则,`set test ok`则为:
```
*3\r\n
$3\r\n
set\r\n
$4\r\n
test\r\n
$2\r\n
ok\r\n
```

以`python`为例:
```python
import redis
r = redis.Redis()
r.set('hello', 'world')
```
那么将发送的指令为`*3\r\n$3\r\nset\r\n$5\r\nhello\r\n$5\r\nworld\r\n`，收到的响应为`+OK\r\n`。

### 响应信息
RESP协议中，不同类型的响应信息，会以不同的字符开头，比如上例中，`+OK\r\n`就以`+`开头。

+ 简单字符串(Simple Strings)响应会以"+"开头
    >+OK\r\n

+ 错误(Errors)响应会以"-"开头

    > -ERR unkown command 'ST'\r\n

+ 数字(Integer)响应会以":"开头

    > :2\r\n

+ 大字符串(Bulk Strings)会以"$"开头，并且随之标出字符串字节数

    >$13\r\nHello, World!\r\n

+ 数组类型(Arrays)类似与请求信息的序列化一致（在`HGETALL``LRANGE``MGET`命令中会返回)。

## 实例
接下来，我们将用go实现一个简单的redis客户端
```go
// file is kv.go
package main

import (
	"log"
	"net"
	"os"
	"strconv"
	"strings"
)

// serialize将待发送的命令按RESP协议处理成合法的字符串
func serialize(args []string) []byte {
	r := []string{
		"*" + strconv.Itoa(len(args)),
	}

	for _, arg := range args {
		r = append(r, "$"+strconv.Itoa(len(arg)))
		r = append(r, arg)
	}

	str := strings.Join(r, "\r\n")
	return []byte(str + "\r\n")
}

// parseResponse解析响应信息
func parseResponse(r []byte, n int) string {
	flag := r[0]
	switch flag {
	case '+':
		return string(r[1 : n-2])
	case '-':
		return string(r[1 : n-2])
	case ':':
		return string(r[1 : n-2])
	case '$':
		var pos int
		for i, v := range r {
			if v == '\n' {
				pos = i
				break
			}
		}
		return string(r[pos+1 : n-2])
	case '*':
		out := []byte{}
		canAdd := false
		for _, current := range r {
			if canAdd {
				if current == '*' || current == '$' {
					canAdd = false
				} else {
					if current != '\n' && current != '\r' {
						out = append(out, current)
					}
				}
			} else {
				if current == '\n' {
					canAdd = true
				}
			}
		}
		return string(out)
	default:
		return ""
	}
}

func main() {
	// 获取所需执行的命令
	args := os.Args[1:]
	if len(args) <= 0 {
		log.Fatalln("需要一个以上参数")
	}

	// 获取redis连接
	redisConn, err := net.Dial("tcp", "127.0.0.1:6379")
	if err != nil {
		log.Fatalln(err.Error())
	}
	defer redisConn.Close()

	// 发送命令
	command := serialize(args)
	_, err = redisConn.Write(command)

	// 获取响应
	response := make([]byte, 1024)
	n, err := redisConn.Read(response)
	r := response[:n]

	// 打印解析后的响应
	log.Println(parseResponse(r, n))
}
```

执行`go run kv.go set a "hello world"`,将看到返回`OK`。

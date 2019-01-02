---
title: "谈谈golang中的锁"
date: 2018-12-28T15:26:58+08:00
tags: ["golang", "并发", "锁"]
categories: ["golang"]
draft: false
---

得益于go的goroutine，go的并发变得十分容易，只需要`go`关键字，就可以启动一个新的协程。
例如一下程序:
``` go
package main

import (
	"fmt"
	"time"
)

func do() {
	time.Sleep(1 * time.Second)
	count++
}

var count int

// 10秒后会看到打印出10
func main() {
	for i := 0; i < 10; i++ {
		do()
	}
	fmt.Println(count)
}
```

在以上例子中，我们对count执行累加操作，这个例子，可以用go关键字并发操作`do`,如下:
``` go
package main

import (
	"fmt"
	"sync"
	"time"
)

var count int
var wg sync.WaitGroup

func do() {
	time.Sleep(1 * time.Second)
	count++
	// 通知协程执行完毕
	wg.Done()
}

// 1秒后打印出10（不保证一定为0)
func main() {
	n := 10
	for i := 0; i < n; i++ {
		// 记录新增一个协程
		wg.Add(1)
		go do()
	}
	// 等待所有协程执行完毕
	wg.Wait()
	fmt.Println(count)
}
```
可以看到，代表中额外加了`sync.WaitGroup`相关的东西，这些内容是为了保证，在协程都执行完毕后，主进程(也可以是协程)才继续执行，否则在计数完成前，主进程就退出，这一切工作都没有意义了。

通过`goroutine`，原来10s的计算仅需1s。在上面的例子中，我们并发了10个goroutine，他们都对同一资源`count`进行了操作, 其实这里已经出问题了， 但是并发数太少，所以不容易观测出问题。

做一下尝试，将for循环中的n改为1000，多执行几次，发现运行结果可能为`945 965 948`。问题出在这里`count++`其中应该拆分为`temp := count; count = temp + 1`, 当在获取temp=99之后，可能其他协程已经对count完成了累加操作，count变为100, 但当前协程依旧执行`count=99+1`，这就导致某些提交没有生效。

怎么避免这个问题呢？我们需要对某一资源的访问做限制，也就是当某一协程在访问某一资源时，要限制其他协程访问。简单来说，就是`加锁`。
``` go
package main

import (
	"fmt"
	"sync"
	"time"
)

var count int
var mux sync.Mutex
var wg sync.WaitGroup

func doCount() {
	time.Sleep(1 * time.Second)
	// 加锁
	mux.Lock()
	count++
	// 释放锁
	mux.Unlock()
	wg.Done()
}

func main() {
	n := 1000
	for i := 0; i < n; i++ {
		wg.Add(1)
		go doCount()
	}
	wg.Wait()
	fmt.Println(count)
}
```

通过在`count++`上下前后添加锁，现在的版本运行之后结果始终为1000。`Lock`与`UnLock`使得他们之间的代码块，同一时间，只有一个协程可以执行到。

在这个例子中，对锁的应用简陋，在实际运用中，需要注意以下两点: 
+ 一个应用中会存在多把锁，不应该用全局变量声明锁，最好能与相关的资源封装进用一结构体内。
+ 假如某一处在持有锁的时候出异常了，导致没办法释放锁，影响其他协程的运行，所以在可能出问题的函数内，使用`defer`确保函数返回前，锁被正常释放。
+ 尽量缩减锁的区域，例如在上例中，假如在`time.Sleep(1 * time.Second)`之前就加锁，导致所有协程都阻塞。原则上，只需要可能引发竞态的地方加锁。

采用以上建议，可以重构代码为:
``` go
package main

import (
	"fmt"
	"sync"
	"time"
)

type Counter struct {
	count int          // 记录计数
	mu    sync.Mutex   // 当前资源的锁
}

func (c *Counter) Add(num int) {
	// 加锁
	c.mu.Lock()
	c.count = c.count + num
	// 释放锁
	c.mu.Unlock()
}

func doCount(counter *Counter, wg *sync.WaitGroup) {
	wg.Add(1)
	time.Sleep(1 * time.Second)
	counter.Add(1)
	wg.Done()
}

func main() {
	wg := &sync.WaitGroup{}
	counter := &Counter{}
	for i := 0; i < 1000; i++ {
		go doCount(counter, wg)
	}
	wg.Wait()
	fmt.Println(counter.count)
}
```

到这里， 就介绍完了go中的互斥锁。等等…也就是说，还有另一种锁？那是当然啦。考虑一种使用场景，较少的协程对某一资源执行`写`操作，而更多的协程执行`读`操作，采用`sync.Mutex`即互斥锁，会导致每一次对资源的访问，无论是读还是写，都会阻塞。实际上，执行读操作的时候，并不会对资源进行更改，所以应该允许其他协程同时读取资源(可重入锁)，且不允许其他协程`写`。而在`写`的时候，应该限制其他协程的`读`与`写`（这里读写互斥，是因为要防止协程读到不应存在的中间态）。这里就使用到了go提供的`sync.RWMutex`(读写锁)。 `RWMutex`是基于Mutex实现的读写互斥锁，一个goroutine可以持有多个读锁或者一个写锁，同一时刻只能持有读锁或者写锁。

使用方法如下:
``` go
package main

import (
	"fmt"
	"sync"
	"time"
)

type MultiCounter struct {
	store map[string]int
	rw    sync.RWMutex
}

func (m *MultiCounter) Add(key string, num int) {
	m.rw.Lock()
	m.store[key] = m.store[key] + num
	m.rw.Unlock()
}

func (m *MultiCounter) Read(key string) int {
	m.rw.RLock()
	defer m.rw.RUnlock()
	return m.store[key]
}

func doCount(counter *MultiCounter, wg *sync.WaitGroup) {
	wg.Add(1)
	time.Sleep(1 * time.Second)
	counter.Add("a", 1)
	wg.Done()
}

func main() {
	wg := &sync.WaitGroup{}
	counter := &MultiCounter{store: make(map[string]int)}
	for i := 0; i < 1000; i++ {
		go doCount(counter, wg)
	}
	fmt.Println(counter.Read("a"))
	wg.Wait()
	fmt.Println(counter.Read("a"))
}
```

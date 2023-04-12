## 1 为什么会有信道

　　协程（goroutine）算是Go的一大新特性，也正是这个大杀器让Go为很多路人驻足欣赏，让信徒们为之欢呼津津乐道。

　　协程的使用也很简单，在Go中使用关键字“go“后面跟上要执行的函数即表示新启动一个协程中执行功能代码。

```go
func main() {
    go test()
    fmt.Println("it is the main goroutine")
    time.Sleep(time.Second * 1)
}
 
func test() {
    fmt.Println("it is a new goroutine")
}
　
```
　　可以简单理解为，Go中的协程就是一种更轻、支持更高并发的并发机制。

　　仔细看上面的main函数中有一个休眠一秒的操作，如果去掉该行，则打印结果中就没有“it is a new goroutine”。这是因为新启的协程还没来得及运行，主协程就结束了。

 

　　所以这里有个问题，我们怎么样才能让各个协程之间能够知道彼此是否执行完毕呢？

　　显然，我们可以通过上面的方式，让主协程休眠一秒钟，等等子协程，确保子协程能够执行完。但作为一个新型语言不应该使用这么low的方式啊。连Java这位老前辈都有Future这种异步机制，而且可以通过get方法来阻塞等待任务的执行，确保可以第一时间知晓异步进程的执行状态。

　　所以，Go必须要有过人之处，即另一个让路人侧目，让信徒为之疯狂的特性——信道（channel）。

 

## 2 信道如何使用

　　信道可以简单认为是协程goroutine之间一个通信的桥梁，可以在不同的协程里互通有无穿梭自如，且是线程安全的。

### 2.1 信道分类

　　信道分为两类

**无缓冲信道**

```go
ch := make(chan string)
```

**有缓冲信道**
```go
ch := make(chan string, 2)
```

### 2.2 两类信道的区别

　　1、从声明方式来看，有缓冲带了容量，即后面的数字，这里的2表示信道可以存放两个stirng类型的变量

　　2、无缓冲信道本身不存储信息，它只负责转手，有人传给它，它就必须要传给别人，如果只有进或者只有出的操作，都会造成阻塞。有缓冲的可以存储指定容量个变量，但是超过这个容量再取值也会阻塞。

 

### 2.3 两种信道使用举例

无缓冲信道
```go
func main() {
    ch := make(chan string)
    go func() {
        ch <- "send"
    }()
     
    fmt.Println(<-ch)
}
　　
```
　　在主协程中新启一个协程且是匿名函数，在子协程中向通道发送“send”，通过打印结果，我们知道在主线程使用<-ch接收到了传给ch的值。

　　<-ch是一种简写方式，也可以使用str := <-ch方式接收信道值。

　　上面是在子协程中向信道传值，并在主协程取值，也可以反过来，同样可以正常打印信道的值。

```go
func main() {
    ch := make(chan string)
    go func() {
        fmt.Println(<-ch)
    }()
 
    ch <- "send"
}
　　
```
有缓冲信道

```go
func main() {
    ch := make(chan string, 2)
    ch <- "first"
    ch <- "second"
     
    fmt.Println(<-ch)
    fmt.Println(<-ch)
}
```
执行结果为
```
first
second
```
　　信道本身结构是一个先进先出的队列，所以这里输出的顺序如结果所示。

　　从代码来看这里也不需要重新启动一个goroutine，也不会发生死锁（后面会讲原因）。

 

## 3 信道的关闭和遍历

### 3.1 关闭

　　信道是可以关闭的。对于无缓冲和有缓冲信道关闭的语法都是一样的。

close(channelName)
　　注意信道关闭了，就不能往信道传值了，否则会报错。

```go
func main() {
    ch := make(chan string, 2)
    ch <- "first"
    ch <- "second"
 
    close(ch)
 
    ch <- "third"
}
```
```
panic: send on closed channel
```
### 3.2 遍历

　　有缓冲信道是有容量的，所以是可以遍历的，并且支持使用我们熟悉的range遍历。
```go
func main() {
    chs := make(chan string, 2)
    chs <- "first"
    chs <- "second"
 
    for ch := range chs {
        fmt.Println(ch)
    }
}
```
输出结果为
```
first
second
fatal error: all goroutines are asleep - deadlock!
```
　　没错，如果取完了信道存储的信息再去取信息，也会死锁（后面会讲）

 

## 4 信道死锁

　　有了前面的介绍，我们大概知道了信道是什么，如何使用信道。

　　下面就来说说信道死锁的场景和为什么会死锁（有些是自己的理解，可能有偏差，如有问题请指正）。

 

### 4.1 死锁现场1

```go
func main() {
    ch := make(chan string)
     
    ch <- "channelValue"
}

func main() {
    ch := make(chan string)
     
    <-ch
}
```
　　　这两种情况，即无论是向无缓冲信道传值还是取值，都会发生死锁。

 

原因分析

　　如上场景是在只有一个goroutine即主goroutine的，且使用的是无缓冲信道的情况下。

　　前面提过，无缓冲信道不存储值，无论是传值还是取值都会阻塞。这里只有一个主协程的情况下，第一段代码是阻塞在传值，第二段代码是阻塞在取值。因为一直卡住主协程，系统一直在等待，所以系统判断为死锁，最终报deadlock错误并结束程序。

 

延伸
```go
func main() {
    ch := make(chan string)
    go func() {
        ch <- "send"
    }()
}
```
　　这种情况不会发生死锁。

　　有人说那是因为主协程发车太快，子协程还没看到，车就开走了，所以没来得及抱怨（deadlock）就结束了。

 

　　其实不是这样的，下面举个反例
```go
func main() {
    ch := make(chan string)
    go func() {
        ch <- "send"
    }()
 
    time.Sleep(time.Second * 3)
}
```
　　这次主协程等你了三秒，三秒你总该完事了吧？！

　   但是从执行结果来看，并没有子协程因为一直阻塞就造成报死锁错误。

　　这是因为虽然子协程一直阻塞在传值语句，但这也只是子协程的事。外面的主协程还是该干嘛干嘛，等你三秒之后就发车走人了。因为主协程都结束了，所以子协程也只好结束（毕竟没搭上车只能回家了，光杵在哪也于事无补）

 

### 4.2 死锁现场2

　　紧接着上面死锁现场1的延伸场景，我们提到延伸场景没有死锁是因为主协程发车走了，所以子协程也只能回家。也就是两者没有耦合的关系。

　　如果两者通过信道建立了联系还会死锁吗？
```go
func main() {
    ch1 := make(chan string)
    ch2 := make(chan string)
    go func() {
        ch2 <- "ch2 value"
        ch1 <- "ch1 value"
    }()
     
    <- ch1
}
```go
执行结果为
```
fatal error: all goroutines are asleep - deadlock!
```
　　没错，这样就会发生死锁。

 

原因分析

　　上面的代码不能保证是主线程的<-ch1先执行还是子协程的代码先执行。

　　如果主协程先执行到<-ch1，显然会阻塞等待有其他协程往ch1传值。终于等到子协程运行了，结果子协程运行ch2 <- "ch2 value"就阻塞了，因为是无缓冲，所以必须有下家接收值才行，但是等了半天也没有人来传值。

　　所以这时候就出现了主协程等子协程的ch1，子协程在等ch2的接收者，ch1<-“ch1 value”语句迟迟拿不到执行权，于是大家都在相互等待，系统看不下去了，判定死锁，程序结束。

　　相反执行顺序也是一样。

 

延伸

　　有人会说那我改成这样能避免死锁吗
```go
func main() {
    ch1 := make(chan string)
    ch2 := make(chan string)
    go func() {
        ch2 <- "ch2 value"
        ch1 <- "ch1 value"
    }()
 
    <- ch1
    <- ch2
}
```
　　不行，执行结果依然是死锁。因为这样的顺序还是改变不了主协程和子协程相互等待的情况，即死锁的触发条件。

　　改为下面这样就可以正常结束
```go
func main() {
    ch1 := make(chan string)
    ch2 := make(chan string)
    go func() {
        ch2 <- "ch2 value"
        ch1 <- "ch1 value"
    }()
 
    <- ch2
    <- ch1
}
```
借此，通过下面的例子再验证上面死锁现场1是因为主协程没受到死锁的影响所以不会报死锁错误的问题

```go
func main() {
    ch1 := make(chan string)
    ch2 := make(chan string)
    go func() {
        ch2 <- "ch2 value"
        ch1 <- "ch1 value"
    }()
 
    go func() {
        <- ch1
        <- ch2
    }()
 
    time.Sleep(time.Second * 2)
}
```
我们刚刚看到如果
```
<- ch1
<- ch2
```
　　放到主协程，则会因为相互等待发生死锁。但是这个例子里，将同样的代码放到一个新启的协程中，尽管两个子协程存在阻塞死锁的情况，但是不会影响主协程，所以程序执行不会报死锁错误。

 

### 4.3 死锁现场3
```go
func main() {
    chs := make(chan string, 2)
    chs <- "first"
    chs <- "second"
 
    for ch := range chs {
        fmt.Println(ch)
    }
}
```
输出结果为
```
first
second
fatal error: all goroutines are asleep - deadlock!
```
原因分析

　　为什么会在输出完chs信道所有缓存值后会死锁呢？

　　其实也很简单，虽然这里的chs是带有缓冲的信道，但是容量只有两个，当两个输出完之后，可以简单的将此时的信道等价于无缓冲的信道。

　　显然对于无缓冲的信道只是单纯的读取元素是会造成阻塞的，而且是在主协程，所以和死锁现场1等价，故而会死锁。

 

## 5 总结

1、信道是协程之间沟通的桥梁

2、信道分为无缓冲信道和有缓冲信道

3、信道使用时要注意是否构成死锁以及各种死锁产生的原因
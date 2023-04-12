## goroutines
- Go 协程意味着并行（或者可以以并行的方式部署）
- Go 协程通过通道来通信；协程通过让出和恢复操作来通信

```go
//并行，这里并没有和其他协程通信
func main() {
fmt.Println("In main()")
go longWait()
go shortWait()
fmt.Println("About to sleep in main()")
// sleep works with a Duration in nanoseconds (ns) !
time.Sleep(10 * 1e9)
fmt.Println("At the end of main()")
}
func longWait() {
fmt.Println("Beginning longWait()")
time.Sleep(5 * 1e9) // sleep for 5 seconds
fmt.Println("End of longWait()")
}
func shortWait() {
fmt.Println("Beginning shortWait()")
time.Sleep(2 * 1e9) // sleep for 2 seconds
fmt.Println("End of shortWait()")
}

```
## 协程间通信
Go 协程通过通道来通信；协程通过让出和恢复操作来通信。

通道实际上是类型化消息的队列：使数据得以传输。它是先进先出（FIFO）的结构所以可以保证发送给他们的元素的顺序（有些人知道，通道可以比作 Unix shells 中的双向管道（two-waypipe））。通道也是引用类型。

**通道操作符 <-**
操作符 `<-`既用于发送也用于接收，Go会根据操作对象明白是发送还是接收。
- 发送（流向通道）
```go
ch <- int1
```
- 接收 （通道流出）
有三种方式
```go
//1.int2未声明，变量int2从通道接收数据
int2 := <- ch
//2.int2已声明
var int2 chan int
int2 = <- ch
//3.可以单独调用获取通道的（下一个）值，当前值会被丢弃，但是可以用来验证，所以以下代码是合法的 
//<- ch
if <- ch != 1000{
    ...
}

//还可以通过以下验证通道是否被关闭
// Note: Only the sender should close a channel, never the receiver. Sending on a closed channel will cause a panic.

// Another note: Channels aren't like files; you don't usually need to close them. Closing is only necessary when the receiver must be told there are no more values coming, such as to terminate a range loop.
ok,v:=<-ch
```

## 通道阻塞
默认情况下，通信是同步且无缓冲的：在有接受者接收数据之前，发送不会结束。可以想象一个无缓冲的通道在没有空间来保存数据的时候：必须要一个接收者准备好接收通道的数据然后发送者可以直接把数据发送给接收者。`所以通道的发送/接收操作在对方准备好之前是阻塞的`：
1）对于同一个通道，发送操作（协程或者函数中的），在接收者准备好之前是阻塞的：如果ch中的数据无人接收，就无法再给通道传入其他数据：新的输入无法在通道非空的情况下传入。所以发送操作会等待 ch 再次变为可用状态：就是通道值被接收时（可以传入变量）。
2）对于同一个通道，接收操作是阻塞的（协程或函数中的），直到发送者可用：如果通道中没有数据，接收者就阻塞了。

**官网说明：**
`**By default, sends and receives block until the other side is ready. This allows goroutines to synchronize without explicit locks or condition variables.**`


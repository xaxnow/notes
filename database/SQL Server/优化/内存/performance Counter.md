## SQLServer:Buffer Manager 


监视Buffer Pool：
1. 内存存储数据页、内部数据结构和过程缓存
2. sql server读取和写入数据库页时的物理I/O
3. 缓冲池扩展（2019新特性），用于使用快速的非易失性存储（如固态驱动器）扩展缓冲区缓存
- Background writer pages/sec 
- Buffer cache hit ratio : 缓冲区高速缓存中找到而不需要从磁盘读取的页的百分比。一般小于95%就表示有问题了。 
- Buffer cache hit ratio base 
- Checkpoint pages/sec ：要求刷新所有脏页的检查点或其他操作每秒刷新到磁盘的页数。和内存压力无关，和用户行为有关。如果操作主要是读，则值比较小。否则insert、update、delete比较多，值就较大。通常用来分析Disk I/O。  
- Database pages : 缓冲池中有数据库内容的页数。即Database Cache大小。
- Extension allocated pages 
- Extension free pages   
- Extension in use as percentage   
- Extension outstanding IO counter   
- Extension page evictions/sec 
- Extension page reads/sec  
- Extension page unreferenced time   
- Extension page writes/sec 
- Free list stalls/sec ：指示每秒必须等待空闲页的请求数。  
- Integral Controller Slope 
- Lazy writes/sec ：每秒被缓冲区管理器的惰性编写器（Lazy writer）写入的缓冲数。惰性编写器是一个系统进程，用于成批刷新脏的老化的缓冲区（包括更改的）。所以当内存有压力时就会触发清理动作。
- Page life expectancy ： 页若不被引用，将在缓冲区停留的秒数。如果没有新的内存需求或有足够的空余就不会出发Lazy Writer，页面会一直在缓冲池里，值就会保持一个较高的水平。如果出现内存压力，值突然下降或忽高忽低，不能维持一个较高水平，就表示有压力。  max instance mem/4*300
- Page lookups/sec 
- Page reads/sec ： 每秒发出的物理数据库页读取数。是所有数据库间的物理页读取总数。如果用户访问的数据都缓存在内存里，则不需要从磁盘读取。所以当Page reads/sec比较高时，一般Page life expectancy会下降，Lazy writes/sec上升。
由于物理I/O对性能影响较大，所以可以通过使用更大数据缓存、智能索引、更改数据库设计等降低I/O
- Page writes/sec :每秒执行的物理数据库页写入数。跟内存压力无关，与用户修改量有关。
- Readahead pages/sec   
- Readahead time/sec   
- Target pages ：缓冲池理想的页数。

## SQLServer:Memory Manager
监视服务器内存总体使用情况。

- Connection Memory (KB) ：服务器用于维护连接的动态内存总量。
- Database Cache Memory (KB) :数据库数据页缓存内存总量  
- External benefit of memory   
- Free Memory (KB) ：缓冲池提交（Committed）的数据页内存为被使用的内存总量
- Granted Workspace Memory (KB) ：当前给予哈希、排序、大容量复制和索引创建等进程的内存总量。
- Lock Blocks    
- Lock Blocks Allocated 
- Lock Memory (KB) ：服务器用于锁的动态内存总量 
- Lock Owner Blocks  
- Lock Owner Blocks Allocated   
- Log Pool Memory (KB) ：服务器用于Log Pool的动态内存总量
- Maximum Workspace Memory (KB) ：最大可用的工作空间内存。 
- Memory Grants Outstanding  ：已成功获取工作区内存授予的进程总数 
- Memory Grants Pending ：等待工作空间内存授权的总数。不等于0，说明用户申请内存被延迟。意味严重内存瓶颈。
- Optimizer Memory (KB) : 服务器用于查询优化的动态内存总数
- Reserved Server Memory (KB)  ：表明服务器为将来使用而保留的内存量。此计数器显示最初授予的当前未使用的内存量，如Granted Workspace Memory (KB)。 
- SQL Cache Memory (KB) :服务器正在用于动态SQL Server高速缓存的动态内存总数。 
- Stolen Server Memory (KB) ：数据库页以外内存   
- Target Server Memory (KB) ： 服务器能够使用的内存总量。当Total小于Target时表明SQL Server还没用足系统给SQL Server的内存。而当因系统内存压力Target变小时，就可能小于Total。此时SQL Server会努力清除缓存，降低内存使用量，直到Total和Target一样大。   当前sql能够使用的。sp_configure 'max server memory (MB)'
- Total Server Memory (KB) ：缓冲池提交（Committed）的数据页内存。不是总大小，是Buffer Pool大小。   当前buffer pool使用的。

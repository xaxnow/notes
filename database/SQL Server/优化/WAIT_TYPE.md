## 等待事件sql
```sql
--非用户等待事件
SELECT DISTINCT
wt.wait_type
FROM sys.dm_os_waiting_tasks AS wt
JOIN sys.dm_exec_sessions AS s ON wt.session_id = s.session_id
WHERE s.is_user_process = 0
--top 10等待事件
SELECT TOP 10
wait_type ,
max_wait_time_ms wait_time_ms ,
signal_wait_time_ms ,
wait_time_ms - signal_wait_time_ms AS resource_wait_time_ms ,
100.0 * wait_time_ms / SUM(wait_time_ms) OVER ( )
AS percent_total_waits ,
100.0 * signal_wait_time_ms / SUM(signal_wait_time_ms) OVER ( )
AS percent_total_signal_waits ,
100.0 * ( wait_time_ms - signal_wait_time_ms )
/ SUM(wait_time_ms) OVER ( ) AS percent_total_resource_waits
FROM sys.dm_os_wait_stats
WHERE wait_time_ms > 0 -- remove zero wait_time
AND wait_type NOT IN -- filter out additional irrelevant waits
( 'SLEEP_TASK', 'BROKER_TASK_STOP', 'BROKER_TO_FLUSH',
'SQLTRACE_BUFFER_FLUSH','CLR_AUTO_EVENT', 'CLR_MANUAL_EVENT',
'LAZYWRITER_SLEEP', 'SLEEP_SYSTEMTASK', 'SLEEP_BPOOL_FLUSH',
'BROKER_EVENTHANDLER', 'XE_DISPATCHER_WAIT', 'FT_IFTSHC_MUTEX',
'CHECKPOINT_QUEUE', 'FT_IFTS_SCHEDULER_IDLE_WAIT',
'BROKER_TRANSMITTER', 'FT_IFTSHC_MUTEX', 'KSOURCE_WAKEUP',
'LOGMGR_QUEUE', 'ONDEMAND_TASK_QUEUE',
'REQUEST_FOR_DEADLOCK_SEARCH', 'XE_TIMER_EVENT', 'BAD_PAGE_PROCESS',
'DBMIRROR_EVENTS_QUEUE', 'BROKER_RECEIVE_WAITFOR',
'PREEMPTIVE_OS_GETPROCADDRESS', 'PREEMPTIVE_OS_AUTHENTICATIONOPS',
'WAITFOR', 'DISPATCHER_QUEUE_SEMAPHORE', 'XE_DISPATCHER_JOIN',
'RESOURCE_QUEUE' )
ORDER BY wait_time_ms DESC
```
## 等待事件类型
```
CXPACKET:某些查询是并行的
SOS_SCHEDULER_YIELD:系统中执行的生产调度超量,CPU不足
THREADPOOL:任务等待工作线程绑定它.CPU不足,在处理并行任务,阻塞
LCK_*:有阻塞,一个会话等待获得一个类型的锁,但已被另一个会话持有
PAGEIOLATCH_*, IO_COMPLETION, WRITELOG:磁盘IO瓶颈有关,通常是查询消耗过多的内存,pageiolatch_*与读写数据文件相关,writelog则是写入日志
PAGELATCH_*:分配争用相关,比如在tempdb中大量创建和销毁对象
LATCH_*:用于短期内对内部缓存对象得保护(不是缓冲区)
ASYNC_NETWORK_IO:网络瓶颈.通常是客户端在逐行处理server端数据
```
## 重置
```
DBCC SQLPERF('sys.dm_os_wait_stats', clear)
```
## 主要性能计数器
• SQLServer:Access Methods\Full Scans/sec
• SQLServer:Access Methods\Index Searches/sec
• SQLServer:Buffer Manager\Lazy Writes/sec
• SQLServer:Buffer Manager\Page life expectancy
• SQLServer:Buffer Manager\Free list stalls/sec
• SQLServer:General Statistics\Processes Blocked
• SQLServer:General Statistics\User Connections
• SQLServer:Locks\Lock Waits/sec
• SQLServer:Locks\Lock Wait Time (ms)
• SQLServer:Memory Manager\Memory Grants Pending
• SQLServer:SQL Statistics\Batch Requests/sec
• SQLServer:SQL Statistics\SQL Compilations/sec
• SQLServer:SQL Statistics\SQL Re-Compilations/sec

### CPU性能计数器
```
Processor/ %Privileged Time
Processor/ %User Time
Process (sqlservr.exe)/ %Processor Time
消耗CPU的
• SQLServer:SQL Statistics/Auto-Param Attempts/sec
• SQLServer:SQL Statistics/Failed Auto-params/sec
• SQLServer:SQL Statistics/Batch Requests/sec
• SQLServer:SQL Statistics/SQL Compilations/sec
• SQLServer:SQL Statistics/SQL Re-Compilations/sec
• SQLServer:Plan Cache/Cache hit Ratio

1.sys.dm_os_wait_stats
2.sys.dm_os_wait_stats,sys.dm_os_scheduler
3.sys.dm_exec_query_stats,sys.dm_query_sql_text
4.sys.dm_os_waiting_tasks
5.sys.dm_exec_requests

sql server scheduler 是非抢占式(cooperative multi-task)的调度,即依赖其他任务自动放弃资源.而Windows scheduler是抢占式的(per-emptive multi-task).
SOS_SCHEDULER_YIELD:一个自愿放弃cpu并重新等待取得执行机会的任务,回到可运行的队列中
CXPACKET:对于在多个处理器之间并行运行的查询，CXPACKET等待在工作程序之间的查询处理器交换迭代器同步期间发生。
CMEMTHREAD
```
## 执行计划
```
DDL语句会清除执行计划
sys.dm_exec_query_stats
```

```

```
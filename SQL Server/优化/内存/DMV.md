# DMV
SQL server 使用Memory Clerk的方式统一管理内存的分配和回收。所有的SQL SErver代码申请或释放内存，都需要通过它们各自的Clerk。这些Clerk之间互相协调，如果某个Clerk使用内存多，SQL Server就会通知其他Clerk释放部分内存，让给需要新内存的Clerk。

## sys.dm_os_memory_clerks 
```sql
SELECT TOP(10) mc.[type] AS [Memory Clerk Type], 
       CAST((SUM(mc.pages_kb)/1024.0) AS DECIMAL (15,2)) AS [Memory Usage (MB)] 
FROM sys.dm_os_memory_clerks AS mc WITH (NOLOCK)
GROUP BY mc.[type]  
ORDER BY SUM(mc.pages_kb) DESC OPTION (RECOMPILE);


select type,sum(virtual_memory_reserved_kb) as [VM Reserved],
sum(virtual_memory_committed_kb) as [VM Commited],
sum(awe_allocated_kb) as [AWE Allocated],
sum(shared_memory_reserved_kb) as [SM Reserved],
sum(shared_memory_committed_kb) as [SM Committed],
sum(pages_kb) as [Allocated KB]
--2008
--sum(single_pages_kb) as [SinglePage Allocator],
--sum(multi_pages_kb) as [MultiPage Allocator],
from sys.dm_os_memory_clerks
group by type
order by type
```

## sys.dm_os_buffer_descriptors
如果数据库或对象多次执行结果差异较大，说明为新的数据做了paging，所以缓冲区有压力。
### 每个DB缓存的页数
```sql
SELECT COUNT(*)AS cached_pages_count  
    ,CASE database_id   
        WHEN 32767 THEN 'ResourceDb'   
        ELSE db_name(database_id)   
        END AS database_name  
FROM sys.dm_os_buffer_descriptors  
GROUP BY DB_NAME(database_id) ,database_id  
ORDER BY cached_pages_count DESC;

```
### DB中每个对象缓存的页数
```sql
SELECT COUNT(*)AS cached_pages_count   
    ,name ,index_id   
FROM sys.dm_os_buffer_descriptors AS bd   
    INNER JOIN   
    (  
        SELECT object_name(object_id) AS name   
            ,index_id ,allocation_unit_id  
        FROM sys.allocation_units AS au  
            INNER JOIN sys.partitions AS p   
                ON au.container_id = p.hobt_id   
                    AND (au.type = 1 OR au.type = 3)  
        UNION ALL  
        SELECT object_name(object_id) AS name     
            ,index_id, allocation_unit_id  
        FROM sys.allocation_units AS au  
            INNER JOIN sys.partitions AS p   
                ON au.container_id = p.partition_id   
                    AND au.type = 2  
    ) AS obj   
        ON bd.allocation_unit_id = obj.allocation_unit_id  
WHERE database_id = DB_ID()  
GROUP BY name, index_id   
ORDER BY cached_pages_count DESC;
```
## sys.dm_exec_cached_plans

可以查看执行计划缓存了哪些东西，哪些占用内存
```sql
select objtype,sum(size_in_bytes)as sum_size_in_bytes,
count(bucketid) as cache_counts
from sys.dm_exec_cached_plans
group by objtype

--具体缓存了哪些对象
SELECT usecounts, cacheobjtype, objtype, text   
FROM sys.dm_exec_cached_plans   
CROSS APPLY sys.dm_exec_sql_text(plan_handle)   
WHERE usecounts > 1   
ORDER BY usecounts DESC;  
GO
```
sys.dm_os_sys_info 
sys.dm_os_buffer_descriptors 
sys.dm_os_memory_objects
sys.dm_os_memory_brokers
## sys.dm_os_ring_buffers
ring buffers在sql server启动期间被创建，记录 SQL Server 系统中的警报以进行内部诊断

```sql
/*
RESOURCE_MEMPHYSICAL_HIGH、RESOURCE_MEMPHYSICAL_LOW、RESOURCE_MEMPHYSICAL_STEADY 或 RESOURCE_MEMVIRTUAL_LOW
*/

DECLARE @runtime datetime  
SET @runtime = GETDATE()  
SELECT CONVERT (varchar(30), @runtime, 121) as data_collection_runtime,   
DATEADD (ms, -1 * (inf.ms_ticks - ring.[timestamp]), GETDATE()) AS ring_buffer_record_time,   
ring.[timestamp] AS record_timestamp, inf.ms_ticks AS cur_timestamp, ring.*   
FROM sys.dm_os_ring_buffers ring  
CROSS JOIN sys.dm_os_sys_info inf where ring_buffer_type='RESOURCE_MEMPHYSICAL_HIGH'
```
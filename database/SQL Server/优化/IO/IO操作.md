# IO操作
## 哪些情况需要和硬盘做交互
1. 内存中没有缓存的数据，需要把数据所在页面读到内存
2. 做insert、update、delete提交前，保证日志记录写到日志文件里
3. checkpoint，把脏数据同步到硬盘
4. buffer pool空间不足，会触发Lazy Writer，主动将内存很久没使用的数据页面和执行计划清空。如果页面有修改还会写回硬盘。
5. 特殊操作：DBCC CheckDB,reindex，update statistics,backup等
   
## 影响IO的设置

1. recovery interval (sp_configure)
2. 数据或日志的自动增长和收缩
3. 数据页面的碎片程度
   碎片越小，数据页面之间排得越紧凑。
   dbcc showconfig
4. 表格上的索引结构
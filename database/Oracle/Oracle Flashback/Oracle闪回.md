1.闪回级别
```sql
--数据库级别	将数据库恢复的过去的某个时间点。适用于误删一个用户，截断一个表。
--表级别	将表闪回删除到过去的某个时间点或某个SCN。闪回drop删除的某个表。
```
2.开启闪回
```sql
archive log list; --归档是否开启
startup mount;
alter database archivelog;
alter database flashback on;
alter database open;
```
3.使用闪回,要到mount状态
```sql
--SQL指令
flashback database to timestamp to_date('2018-08-08 10:09:09','yyyy-mm-dd hh24:mi:ss'); --某个时间点
flashback database to scn 67839;  --某个scn
--rman指令
flashback database to time=to_date('2018-08-08 10:09:09','yyyy-mm-dd hh24:mi:ss');
flashback database to scn=67839;
flashback database to sequence=345 thread=1;--到日志序列号345，不包括345
--验证删除的数据是否恢复
alter database open read only;--可以验证了，如果恢复还可以继续闪回
--恢复数据，打开数据库
startup mount;
alter database open resetlogs;--resetlogs选项可以继续使用闪回
--闪回没达到要求造成错乱
recover database;--撤销闪回
recover database until ...;--恢复到某个时间点
```
4.监控闪回
```sql
v$flashback_database_log    --最小闪回scn
select current_scn from v$database;  --当前scn
v$flashback_database_stat   --闪回日志开销
v$recovery_file_dest    --闪回区大小
```
5.闪回删除
```sql
--使用drop table并未立即删除，只是改了个名字空间依旧被占用。该表的原表名和新表名被记录到recycle bin（回收站）中。
show parameter recyclebin;--是否启用闪回删除
alter system set recyclebin=on scope=both;--开启闪回删除
--查看回收站
user_recyclebin、dba_recyclebin
--恢复删除的表，要在该表的模式下恢复
flashback table table_name to before drop;
--恢复存在同名的表
desc table_name;--table_name是回收站新表名
--永久删除
drop table table_name purge;
purge table table_name;--永久删除在回收站的
```
6.闪回表
```sql
--保存在undo中，在此期间不能进行ddl操作
show parameter undo;--修改undo_retention=...s scope=spfile;
alter table table_name enabled row movement;--启动行移动特性才能闪回表，delete from的表
flashback database to timestamp to_date('2018-08-08 10:09:09','yyyy-mm-dd hh24:mi:ss');--闪回到某个时间
```
7.闪回版本、事务、查询，以及闪回复原点



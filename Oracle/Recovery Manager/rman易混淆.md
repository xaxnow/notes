1.delete expired和delete obsolete区别
```
obsolete:与retention policy相关，当备份或者副本根据保存策略而被丢弃的时候，就会被标记为该状态。比如你设置恢复窗口为7天，今天10号，那2号之前（包括2号）的都被认为是“过期的”。
expired:使用crosscheck对备份进行校验，当备份或者副本被存储在rman目录中，但是并没有物理存在于备份介质上时，就会被标记为该状 态；在操作系统层删除备份集后，用crosscheck 检测后就标志为X（expired）。通常指丢失（被删除）的备份。
```
2.恢复目录catalog
```sql
--创建存放catalog的表空间
create tablespace rcat_tbs datafile '/home/oracle/rcat.dbf' size 300m;
create user rcat_owner identified by oracle default tablespace rcat_tbs temporary tablespace temp quota unlimited on rcat_tbs;
grant recovery_catalog_owner,resource,connect to rcat_owner;
--使用创建的用户连到rman
rman catalog rcat_owner/oracle;
RMAN>create catalog tablespace rcat_tbs;
select table_name from user_tables;
--连接到目标数据库
rman target sys/sys@ip:orcl catalog rcat_owner/oracle@ip:rcat
register database;
--以后每次备份都要连接到恢复目录恢复了
--应该保证备份
resync catalog;--备份出现网络问题或未连接到catalog
```









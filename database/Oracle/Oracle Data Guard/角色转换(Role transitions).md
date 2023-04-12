## 一、Switchover
```
切换通常用于减少计划中断期间的主数据库停机时间，例如操作系统或硬件升级，或Oracle数据库软件和补丁集的滚动升级
```
## 二、Failover
```
故障转移通常仅在主数据库不可用时使用，并且不可能在合理的时间段内将其恢复为服务
在执行failover前尽可能将primary数据库redo复制到standby
将standby数据库置于不是maximum protection模式(因为最大保护模式需要数据绝无丢失)
SQL> ALTER DATABASE SET STANDBY DATABASE TO MAXIMIZE PERFORMANCE;
```
## 三、角色转换前检查
```
确认主库和从库间网络连接通畅；
确认没有活动的会话连接在数据库中；
PRIMARY数据库处于打开的状态，STANDBY数据库处于MOUNT状态；
确保STANDBY数据库处于ARCHIVELOG模式；
如果设置了REDO应用的延迟，那么将这个设置去掉；
确保配置了主库和从库的初始化参数，使得切换完成后，DATA GUARD机制可以顺利的运行。
如果是最大保护模式，先变成最大性能模式：
select switchover_status,database_role,protection_level,open_mode from v$database;
```
## 四、物理standby的switchover
### 1.检查主备是否有日志传输错误及redo gap
```sql
gap原因:归档太大或网络不稳定:
可以加入compression参数:log_archive_dest_2='service=pri async compression=enable'
                        log_archive_dest_state_2=enable
或max_connections参数:log_archive_dest_2='service=pri async max_connections=5'
                        log_archive_dest_state_2=enable
处理gap:                        
备库:
SQL>SELECT * FROM V$ARCHIVE_GAP;
    THREAD# LOW_SEQUENCE# HIGH_SEQUENCE#
	---------- ------------- --------------
     1           138            145
比较主备归档:
SQL>archive log list;

主库:根据线程号和丢失的归档号查询丢失的归档
SQL>SELECT NAME FROM V$ARCHIVED_LOG WHERE THREAD#=1 AND DEST_ID=1 AND SEQUENCE# BETWEEN 138 AND 145;

一.gap少,主库未丢失归档
1.复制查询道德归档到备库
2.将归档注册给备库:
ALTER DATABASE REGISTER LOGFILE '/u01/app/oracle/flash_recovery_area arch/1_139_808409555.arc';
二.gap多或主库丢失归档:基于备库scn增量备份恢复到备库
1.取消备库日志应用
SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE cancel;
2.确定备库需要主库开始增量备份的起点scn
SQL> SELECT CURRENT_SCN FROM V$DATABASE;

CURRENT_SCN
-----------
 3505254
 SQL> select min(checkpoint_change#) from v$datafile_header 
 where file# not in (select file# from v$datafile where enabled = 'READ ONLY');

MIN(CHECKPOINT_CHANGE#)
-----------------------
3.为空启动备库到mount,再执行查询
SQL> select min(checkpoint_change#) from v$datafile_header 
where file# not in (select file# from v$datafile where enabled = 'READ ONLY');

MIN(CHECKPOINT_CHANGE#)
-----------------------
 3505255
 选择上面的结果作为增量备份起点
4.主库基于scn的增量备份
RMAN> BACKUP INCREMENTAL FROM SCN 3505254 DATABASE FORMAT '/tmp/ForStandby_%U' tag 'FORSTANDBY';
5.将备份拷贝到备库,并注册到备库控制文件
拷贝:略
 rman target /

Recovery Manager: Release 11.2.0.4.0 - Production on Thu Mar 29 11:37:52 2018

Copyright (c) 1982, 2011, Oracle and/or its affiliates. All rights reserved.

connected to target database: ORCL (DBID=1484954774, not open)

RMAN> CATALOG START WITH '/tmp/ForStandby';

using target database control file instead of recovery catalog
searching for all files that match the pattern /tmp/ForStandby

List of Files Unknown to the Database
=====================================
File Name: /tmp/ForStandby_08sv0bdj_1_1
File Name: /tmp/ForStandby_07sv0bcg_1_1

Do you really want to catalog the above files (enter YES or NO)? yes
cataloging files...
cataloging done

List of Cataloged Files
=======================
File Name: /tmp/ForStandby_08sv0bdj_1_1
File Name: /tmp/ForStandby_07sv0bcg_1_1
6.使用增量备份恢复备库
RMAN> RECOVER DATABASE NOREDO;

Starting recover at 29-MAR-18
allocated channel: ORA_DISK_1
channel ORA_DISK_1: SID=16 device type=DISK
channel ORA_DISK_1: starting incremental datafile backup set restore
channel ORA_DISK_1: specifying datafile(s) to restore from backup set
destination for restore of datafile 00001: /u01/app/oracle/oradata/rzorcl/system01.dbf
destination for restore of datafile 00002: /u01/app/oracle/oradata/rzorcl/sysaux01.dbf
destination for restore of datafile 00003: /u01/app/oracle/oradata/rzorcl/undotbs01.dbf
destination for restore of datafile 00004: /u01/app/oracle/oradata/rzorcl/users01.dbf
destination for restore of datafile 00005: /u01/app/oracle/oradata/rzorcl/example01.dbf
destination for restore of datafile 00006: /u01/app/oracle/oradata/rzorcl/odc_tps01.dbf
destination for restore of datafile 00007: /u01/app/oracle/oradata/rzorcl/test01.dbf
destination for restore of datafile 00008: /u01/app/oracle/oradata/rzorcl/big01.dbf
destination for restore of datafile 00009: /u01/app/oracle/oradata/rzorcl/big02.dbf
channel ORA_DISK_1: reading from backup piece /tmp/ForStandby_07sv0bcg_1_1
channel ORA_DISK_1: piece handle=/tmp/ForStandby_07sv0bcg_1_1 tag=FORSTANDBY
channel ORA_DISK_1: restored backup piece 1
channel ORA_DISK_1: restore complete, elapsed time: 00:00:01
7.在主库为备库重新备份控制文件,并拷贝到备库
RMAN> BACKUP CURRENT CONTROLFILE FOR STANDBY FORMAT '/tmp/ForStandbyCTRL.bck';
8.备库还原控制文件
RMAN> shutdown immediate;

database dismounted

Oracle instance shut down

RMAN> startup nomount;

connected to target database (not started)
Oracle instance started

Total System Global Area 1002127360 bytes

Fixed Size 2259440 bytes
Variable Size 285214224 bytes
Database Buffers 708837376 bytes
Redo Buffers 5816320 bytes

RMAN> RESTORE STANDBY CONTROLFILE FROM '/tmp/ForStandbyCTRL.bck';
9.备库重启到mount
10.若是OMF管理数据文件,需要在备库控制文件注册控制文件(不是则跳过)
OMF,全称是Oracle_Managed Files,即Oracle文件管理，使用OMF可以简化管理员的管理工作，不用指定文件的名字、大小、路径，其名字，大小，
路径由oracle 自动分配。在删除不再使用的日志、数据、控制文件时，OMF也可以自动删除其对应的OS文件。

1.使用ALTER SYSTEM SET db_create_file_dest = '<path>'设置路径
2.查看刚刚的设置SHOW PARAMETER db_create_file_dest;
3.创建表空间及数据文件CREATE TABLESPACE tablespace_name
4.单独创建表空间CREATE TABLESPACE <> DATAFILE '<path>' SIZE <>;
5.也可以创建undo和temporary tablespace 。CREATE UNDO TABLESPACE tablespace_name ;CREATE TEMPORARY TABLESPACE tablespace_name;
6.删除表空间DROP TABLESPACE tablespace_name ;OMF情况下则删除物理文件，等效于未使用OMF创建，使用INCLUDING CONTENTS AND DATAFILES 删除方式

RMAN> CATALOG START WITH '+DATA/rzorcl/datafile/';

List of Files Unknown to the Database 
===================================== 
File Name: +data/rzorcl/DATAFILE/SYSTEM.309.685535773 
File Name: +data/rzorcl/DATAFILE/SYSAUX.301.685535773 
File Name: +data/rzorcl/DATAFILE/UNDOTBS1.302.685535775 
File Name: +data/rzorcl/DATAFILE/SYSTEM.297.688213333 
File Name: +data/rzorcl/DATAFILE/SYSAUX.267.688213333 
File Name: +data/rzorcl/DATAFILE/UNDOTBS1.268.688213335

Do you really want to catalog the above files (enter YES or NO)? YES 
cataloging files... 
cataloging done

List of Cataloged Files 
======================= 
File Name: +data/rzorcl/DATAFILE/SYSTEM.297.688213333 
File Name: +data/rzorcl/DATAFILE/SYSAUX.267.688213333 
File Name: +data/rzorcl/DATAFILE/UNDOTBS1.268.688213335

确保主库在这个SCN之后没有添加新的数据文件，如果有则需要单独进行备份和还原，参考文档文档 ID 836986.1
SQL> select file#,name from v$datafile where creation_change# > 3505254;

no rows selected

RMAN> SWITCH DATABASE TO COPY;

datafile 1 switched to datafile copy "+DATA/rzorcl/datafile/system.297.688213333" 
datafile 2 switched to datafile copy "+DATA/rzorcl/datafile/undotbs1.268.688213335" 
datafile 3 switched to datafile copy "+DATA/rzorcl/datafile/sysaux.267.688213333"

11.若备库开启了闪回则重新开启
SQL> ALTER DATABASE FLASHBACK OFF; 
SQL> ALTER DATABASE FLASHBACK ON;
12.备库开启日志应用
SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;
```
### 2.检查主库是否支持切换及switchover操作
```SQL
select switchover_status,database_role from v$database;

SWITCHOVER_STATUS    DATABASE_ROLE
-------------------- ----------------
SESSIONS ACTIVE      PRIMARY
-----------------------------------------
1.NOT ALLOWED -这是备用数据库，而没有先切换主数据库，或者这是主数据库，并且没有备用数据库。
2.SESSIONS ACTIVE-表示在允许切换操作之前，需要断开连接到主数据库或备用数据库的活动SQL会话。查询V$SESSION视图以标识需要终止的特定过程。
3.SWITCHOVER PENDING -这是一个备用数据库，并且已收到主数据库切换请求，但未处理。
4.SWITCHOVER LATENT -切换处于挂起模式，但未完成，返回到主数据库。
5.TO PRIMARY -这是一个备用数据库，可以切换到主数据库。
6.TO STANDBY -这是一个主数据库，可以切换到备用数据库。
7.RECOVERY NEEDED -这是一个备用数据库，尚未收到切换请求。
8.PREPARING SWITCHOVER-这是主数据库正在接受来自逻辑备用数据库的重做数据以准备切换到逻辑备用数据库角色，还是这是逻辑备用数据库将重做数据发送到主数据库和其他备用数据库以进行准备切换到主数据库角色。在后一种情况下，已完成的词典已发送到主数据库和其他备用数据库。
9.PREPARING DICTIONARY -这是一个逻辑备用数据库，正在将重做数据发送到配置中的主数据库和其他备用数据库，以准备切换到主数据库角色。
10.TO LOGICAL STANDBY -这是一个主数据库，已从逻辑备用数据库接收到完整的字典。
-----------------------------------------
SQL>alter database commit to switchover to physical standby with session shutdown;

3.执行切换
正常切换:
SQL>alter database commit to switchover to physical standby;
如果switchover_status为SESSION ACTIVE则使用:
SQL> alter database commit to switchover to physical standby with session shutdown;
Database altered.
4.查询是否完成切换
SQL>STARTUP MOUNT
SQL> select switchover_status,database_role,protection_level,open_mode from v$database;

SWITCHOVER_STATUS    DATABASE_ROLE    PROTECTION_LEVEL     OPEN_MODE
-------------------- ---------------- -------------------- --------------------
RECOVERY NEEDED      PHYSICAL STANDBY MAXIMUM PERFORMANCE  READ ONLY
切换后会自动关闭数据库,所以需开启数据库
SQL>ALTER DATABASE OPEN;

5.RECOVERY NEEDED 是因为还没有同步日志(standby切换为primary后执行)
所以后面需要备库开启日志应用,主库切换日志
```
### 3.检查备库是否支持切换及switchover操作
```SQL
SQL> select switchover_status,database_role from v$database;

SWITCHOVER_STATUS    DATABASE_ROLE
-------------------- ----------------
NOT ALLOWED          PHYSICAL STANDBY
1.TO  PRIMARY可以切换为主库
SQL>alter database commit to switchover to primary;
2.SESSION ACTIVE就应该断开活动会话
SQL>alter database commit to switchover to primary with session shutdown;
3.NOT ALLOWED说明切换标记还没收到，此时不能执行转换。(需要开启redo应用)

4.执行切换
SQL> alter database commit to switchover to primary with session shutdown;

Database altered.
5.检查状态(是primary了,状态可能是TO STANDBY或NOT ALLOWED(因为新备库未开启日志应用))
SQL> select switchover_status,database_role,PROTECTION_LEVEL,OPEN_MODE from v$database;

SWITCHOVER_STATUS    DATABASE_ROLE    PROTECTION_LEVEL     OPEN_MODE
-------------------- ---------------- -------------------- --------------------
TO STANDBY           PRIMARY          MAXIMUM PERFORMANCE  READ WRITE
切换后会自动关闭数据库,所以需开启数据库:
SQL>ALTER DATABASE OPEN;
```
### 4.新备库开启应用日志,主库切换日志
```
备库:
SQL>alter database recover managed standby database disconnect from session;
主库:
SQL>alter database switch logfile;

主备:
SQL>archive log list;(主备看日志序号是否一致)

```
## 二、Failover
### 1.将未应用的redo数据刷到备库
```sql
--将主库设为mount,不能mount则进行下一步
startup mount;
alter system flush redo to 'std_db_unique_name';
--如果语句没错转到步骤5,如果报错或等待时间长主动停止转到步骤2
```
### 2.验证备用数据库是否具有每个主数据库重做线程的最近归档的重做日志文件
```sql
select unique thread# as thread, max(sequence#) over (partition by THREAD#) as last FROM v$archived_log;
--如果可能，将每个主数据库重做线程的最近归档的重做日志文件复制到备用数据库（如果该数据库不存在），并进行注册
alter database register physical logfile 'FILESPEC1';
```
### 3.识别并解决任何存档的重做日志gaps
```sql
select thread#, low_sequence#, high_sequence# from v$archive_gap;

THREAD#    LOW_SEQUENCE# HIGH_SEQUENCE#
---------- ------------- --------------
         1            90             92

--在此示例中，间隙包括存档的重做日志文件，序列号为90,91和92，用于线程1.如果可能，将任何丢失的存档重做日志文件从主数据库复制到目标备用数据库，并将它们注册到目标备用数据库。必须为每个重做线程执行此操作。
alter database register physical logfile 'FILESPEC1';
```
### 4.重复上一步直到没有gaps
```
因为上一步查出的仅为最高的gaps,所以需要重复执行.如果缺少归档,则会有数据丢失
```
### 5.备库停止Redo Apply
```sql
alter database recover managed standby database cancel;
```
### 6.完成应用所有的redo数据
```sql
alter database recover managed standby database finish;
--没报错则到下一步,如果有gaps未解决则尝试解决,否则执行下面SQL(有数据丢失)
alter database activate physical standby database;
--成功到步骤9
```
### 7.验证目标备用数据库是否已准备好成为主数据库
```sql
select switchover_status from v$database;

switchover_status
-----------------
TO PRIMARY
```
### 8.将物理备用数据库切换为主角色
```sql
alter database commit to switchover to primary [with session shutdown;]
--上一步是to primary 就可以省略with session shutdown;
```
### 9.开启备库作为新的主库
```sql
alter database open;
```
### 10.备份整库
### 11.重启其他备库的redo应用
```sql
alter database recover managed standby database using current logfile disconnect from session;
```
### 12.恢复失败主库(可选)


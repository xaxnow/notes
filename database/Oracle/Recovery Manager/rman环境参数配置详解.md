### 1.显示和清除rman配置
```sql
--显示所有配置参数
show all; 
--显示特定配置,只能显示有...TO...的配置
SHOW RETENTION POLICY;
SHOW DEFAULT DEVICE TYPE;
--CONFIGURATION ... CLEAR清除配置
CONFIGURE BACKUP OPTIMIZATION CLEAR;
CONFIGURE RETENTION POLICY CLEAR;
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK CLEAR;
```
using target database control file instead of recovery catalog指的是使用目标数据库控制文件代替恢复目录


备份记录的两种模式catalog和nocatlog，参考链接：https://blog.csdn.net/tianlesoftware/article/details/5641763

 show all;	--查看全部配置参数

1.CONFIGURE RETENTION POLICY TO REDUNDANCY 1; # default
```sql
设置rman备份过期条件：是用来决定那些备份不再需要了，它一共有三种可选项，分别是

(1).可以将数据库系统恢复到最近七天内的任意时刻。任何超过最近七天的数据库备份将被标记为obsolete。

CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 7 DAYS;  
(2).保持可以恢复的最新的5份数据库备份，任何超过最新5份的备份都将被标记为redundancy。它的默认值是1份.

这条参数，它规定了数据库全备（也就0级备份的冗余策略），默认该参数冗余为1份，也就是说如果你某年某月某日执行了1次0级备份，那么之前的0级备份和之前的归档日志就全部过时，变成了obsolete状态，然后我们可以使用report obsolete;查看已经过期的全备。注意旧的数据库备份虽然已经被标记obsolete，但是RMAN并不会自动将其删除，必须手动删除。

CONFIGURE RETENTION POLICY TO REDUNDANCY 5;     
(3).不需要保持策略，NONE 可以把使备份保持策略失效.

CONFIGURE RETENTION POLICY TO NONE;　
clear将恢复回默认的保持策略( configure retention policy clear;)。

一般最安全的方法是采用第二种保持策略。

report obsolete          //列出过期
delete obsolete　　      //删除过期
``` 
2.CONFIGURE BACKUP OPTIMIZATION OFF; # default
```sql
默认值为关闭，如果打开，rman将对备份的数据文件及归档等文件进行一种优化的算法。

RMAN中的备份优化(Backup Optimization)是指在备份过程中，如果满足特定条件，RMAN将自动跳过某些文件而不将它们包含在备份集中以节省时间和空间。说的直白些就是能不备的它就不备了，不像原来甭管文件有没有备份过统统再备一遍。通常必须满足如下几个条件的情况下，才能够启用备份优化的功能：
(1).CONFIGURE BACKUP OPTIMIZATION参数置为on；
(2).执行的BACKUP DATABASE或BACKUP ARCHIVELOG命令中带有ALL或LIKE参数。
(3).分配的通道仅使用了一种设备类型，也就是没有同时分配使用sbt与disk的多个通道。
打开备份优化设置通过如下命令：

RMAN> CONFIGURE BACKUP OPTIMIZATION ON;
那么在进行备份优化时，RMAN是如何判断要备份的文件是否需要被优化呢，这个算法就相当复杂了，
而且可能影响优化算法的因素也非常多，假如某库在上午9点被执行过一次全库备份，等下午3点再次执行全库备份时，
备份的文件没有变动而且也已经被备份过时，才会跳过这部分文件。所以理论上备份优化仅对于只读表空间或offline表空间起作用。
当然对于已经备份过的archivelog文件，它也会跳过。

要不要打开：如果之前有备份，开启这个是就会跳过这个之前已经备份了的。这样会提高备份速度。

ps:
在备份副本满足相同保留策略的前提下,不继续创建额外的副本
只适用于归档日志(已经存在的,不变的)或者是只读或者是脱机表空间的备份
因为一旦数据更改或者产生redo之后,备份的数据就会发生改变
 ```
3.CONFIGURE DEFAULT DEVICE TYPE TO DISK; # default
```sql
是指定所有I/O操作的设备类型是硬盘或者磁带，默认值是硬盘。
磁带的设置是
CONFIGURE DEFAULT DEVICE TYPE TO SBT;
```
4.CONFIGURE CONTROLFILE AUTOBACKUP ON; # default
```sql
自动备份控制文件,建议打开,打开之后,RMAN做任何备份操作,都会自动备份controlfile和spfile,储存到RMAN已知的位置.
当controlfile任何副本丢失之后,会去这里面找controlfile的备份,并且还原到spfile指定的位置
假如spfile也丢失了,那么就用只有一个DB_NAME参数的pfie文件启动实例
备份设置：
RMAN> CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '/u01/backup/backupset/conf_%d_%F'; 

new RMAN configuration parameters:
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '/u01/backup/backupset/conf_%d_%F';
new RMAN configuration parameters are successfully stored
 
恢复：
使用RMAN连接之后
set dbid xxxxxxxxxx;
restore spfile from autobackup;　　　　　　　　　//恢复spfile
restore controlfile from autobackup;          //再进行恢复controlfile
到mount之后再继续恢复datafile
和普通的全备的区别是:   全备所备份的controlfile和spfile不能在nomount的时候恢复
 ```
5.CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '%F'; # default
```sql
是配置控制文件的备份路径和备份格式，%F是指一个基于DBID的唯一的名称
configure controlfile autobackup format for device type disk to '/cfs01/backup/conf/conf_%F';
 ```
6、CONFIGURE DEVICE TYPE DISK PARALLELISM 1 BACKUP TYPE TO BACKUPSET; # default
```sql
 --设置并行数（通道数）和备份类型是备份集
device type disk|stb pallelism n backup type to backupset;
复制代码
configure device type disk|stb parallelism 2;
configure device type disk|stb clear; --用于清除上面的信道配置
configure channel device type disk format 'e/:rmanback_%U';
configure channel device type disk maxpiecesize 100m
configure channel device type disk rate 1200K
configure channel 1 device type disk format 'e/:rmanback_%U';
configure channel 2 device type disk format 'e/:rmanback_%U';
configure channel 1 device type disk maxpiecesize 100m
复制代码
 ```
7、CONFIGURE DATAFILE BACKUP COPIES FOR DEVICE TYPE DISK TO 1; # default
```sql
—设置备份副本：数据库的每次备份的copy数量，oracle的每一次备份都可以有多份完全相同的拷贝，默认1份。
```
8、CONFIGURE ARCHIVELOG BACKUP COPIES FOR DEVICE TYPE DISK TO 1; # default
```sql
—同第7，设置归档日志的备份副本
设置数据库的归档日志的存放设备类型
configure datafile|archivelog backup copies for device type disk|stb clear
BACKUP DEVICE TYPE DISK DATABASE FORMAT '/disk1/backup/%U', '/disk2/backup/%U', '/disk3/backup/%U';
 ```
9、CONFIGURE MAXSETSIZE TO UNLIMITED; # default
```sql
配置备份集的大小,一般不使用这个默认值,都是配置备份片的大小
configure maxsetsize to 1G|1000M|1000000K|unlimited;
configure maxsetsize clear;
```
10、CONFIGURE ENCRYPTION FOR DATABASE OFF; # default
```aql
配置加密备份集,能够具体到某个表空间
11、CONFIGURE ENCRYPTION ALGORITHM 'AES128'; # default
```sql
配置加密算法“AES128”，还可以指定AES256；
```
12、CONFIGURE COMPRESSION ALGORITHM 'BASIC' AS OF RELEASE 'DEFAULT' OPTIMIZE FOR LOAD TRUE ; # default
```sql
压缩算法
10G 推出了bzip2算法的压缩备份。 
11R1推出了zlib算法的压缩备份。
11R2推出了基本压缩备份(BASIC)和高级压缩备份(LOW,MEDIUM,HIGH,需要单独付费)。
LOW – 对应 LZO (11gR2) – 最低压缩比，但是最快。
MEDIUM – 对应 ZLIB (11gR1) – 比较好的压缩比，速度慢于LOW 。
HIGH – 对应 unmodified BZIP2 (11gR2) – 最高压缩比，速度也是最慢的。
BASIC (which is free) – 对应 BZIP2 (10g style compression) – 压缩比和MEDIUM差不多 ,但是速度较MEDIUM慢
```
13、CONFIGURE RMAN OUTPUT TO KEEP FOR 7 DAYS; # default
```
设置了 V$RMAN_OUTPUT保留的天数。默认为7天。
```
14、CONFIGURE ARCHIVELOG DELETION POLICY TO NONE; # default
```sql
指定归档文件的删除策略,默认的none就是归档备份完之后就能够被删除
但是在DG环境下的时候,在standby端成功接收并且应用前primary需要始终保存该文件
```
15、CONFIGURE SNAPSHOT CONTROLFILE NAME TO '/u01/app/oracle/product/12.2.0/db_1/dbs/snapcf_gnnt1.f'; # default
```sql
是配置控制文件的快照文件的存放路径和文件名，这个快照文件是在备份期间产生的，用于控制文件的读一致性。
防止备份期间数据库对控制文件的更改(像undo)
默认将快照控制文件名配置为'/u01/app/oracle/product/12.2.0/db_1/dbs/snapcf_gnnt1.f′；
详情：https://blog.csdn.net/leshami/article/details/12754339
```
 16、CONFIGURE CHANNEL DEVICE TYPE DISK FORMAT   '/rmanbackup/%U.dbf'; 
```sql
当通道的介质类型是disk的时候,指定存储位置和命名格式,
建议每次手动指定
 ```
17、CONFIGURE EXCLUDE FOR TABLESPACE <tablespace> [CLEAR];
此命令用于将指定的表空间不备份到备份集中， 此命令对只读表空间是非常有用的。
 ```sql
Rman的format格式中的%
%c 备份片的拷贝数 
%d 数据库名称 
%D 位于该月中的第几天 (DD) 
%M 位于该年中的第几月 (MM) 
%F 一个基于DBID唯一的名称,这个格式的形式为c-IIIIIIIIII-YYYYMMDD-QQ,其中IIIIIIIIII为该数据库的DBID，YYYYMMDD为
日期，QQ是一个1-256的序列 
%n 数据库名称，向右填补到最大八个字符 
%u 一个八个字符的名称代表备份集与创建时间 
%p 该备份集中的备份片号，从1开始到创建的文件数
%U 一个唯一的文件名，代表%u_%p_%c 
%s 备份集的号 
%t 备份集时间戳 
%T 年月日格式(YYYYMMDD)
```

##### 1、RMAN优点

```
支持增量备份：在传统的备份工具（如EXP或EXPDP）中，只能实现一个完整备份而不能增量备份，RMAN采用被备份级别实现增量备份，在一个完整备份的基础上，采用增量备份，和传统的备份方式相比，这样可以减少备份的数据量。
自动管理备份文件：RMAN备份的数据是RMAN自动管理的，包括文件名字、备份文件存储目录，以及识别最近的备份文件，搜索恢复时需要的表空间、模式或数据文件等备份文件。
自动化备份与恢复：在备份和恢复操作时，使用简单的指令就可以实现备份与恢复，且执行过程完全由RMAN自己维护。
不产生重做信息：与用户管理的联机备份不同，使用RMAN的联机备份不产生重做信息。
恢复目录：RMAN的自动化备份与恢复功能应该归功于恢复目录的使用，RMAN直接在其中保存了备份和恢复脚本。
支持映像复制：使用RMAN也可以实现映像复制，映像是以操作系统上的文件格式存在，这种复制方式类似于用户管理的脱机备份方式。
新块的比较特性：这是RMAN支持增量备份的基础，这种特性使得在备份时，跳过数据文件中从未使用过的数据块的备份，备份数据量的减少直接导致了备份存储空间需求和备份时间的减少。
备份的数据文件压缩处理：RMAN提供一个参数，说明是否对备份文件进行压缩，压缩的备份文件以二进制文件格式存在，可以减少备份文件的存储空间。
备份文件有效性检查功能：这种功能验证备份的文件是否可用，在恢复前往往需要验证备份文件的有效性。
```

##### 2、系统架构详解

```
RMAN可执行程序：它是一个客户端工具，用来启动与数据库服务器的连接，从而实现备份与恢复的各种操作。
RMAN客户端：一旦建立了与数据库服务器的会话连接，RMAN可执行程序就创建一个客户端，通过客户端完成与数据库服务器之间的通信，完成各种备份与恢复操作的指令。
RMAN客户端可以连接通过Oracle Net连接到可访问的任何主机上。
服务器进程：在RMAN建立了与数据库服务器的会话连接后，在数据库服务器端启动一个后台进程，它执行RMAN客户端发出的各种数据恢复与备份指令，并完成实际的磁盘或磁带设备的读写任务。
RMAN信息库：RMAN信息库记录了RMAN的一些信息，如备份的数据文件及副本的目录、归档的重做日志备份文件和副本、表空间和数据文件，以及备份或恢复的脚本和RMAN的配置信息。默认使用数据库服务器的控制文件记录这些信息，读者可以通过转储的控制文件发现这些信息，如使用ALTER DATABASE BACKUP CONTROL FILE TOTRACE。
恢复目录：记录RMAN信息库的信息。但是恢复目录需要事先配置，信息库既可以存储在数据库的控制文件中，也可以存储在恢复目录中。在Oracle中默认先将RMAN信息库写入控制文件，如果存在恢复目录则需要继续写到恢复目录。使用控制文件的不足是控制文件中记录RMAN信息库的空间有限，当空间不足时可能被覆盖掉。所以Oracle建议创建单独的恢复目录。这样也可以更好地发挥RMAN提供的新特性。
```

##### 3、快闪恢复区

```
快闪恢复区是存储与备份和恢复数据文件以及相关信息的存储区。快闪恢复区保存了每个数据文件的备份、增量备份、控制文件备份以及归档重做日志备份，Oracle也允许在快闪恢复区中保存联机重做日志的冗余副本以及当前控制文件的冗余副本，还有Oracle中闪回特性中的闪回日志也保存在快闪恢复区中。
3.1 修改快闪恢复区大小
	show prameter db_recovery...
	修改
	alter system set ...
	或者编辑pfile
	查看使用情况
	v$recovery_file_dest
```

##### 4、RMAN的相关概念和配置参数

```
备份集：备份集是一个逻辑数据集合，由一个或多个RMAN的备份片组成，备份片是RMAN格式的操作系统文件，包含数据文件、控制文件或者归档日志文件。默认情况下，在执行RMAN的备份时，将产生备份文件的备份集，备份集只有RMAN可以识别，所以在恢复时必须使用RMAN来访问备份集实现恢复。备份集是RMAN默认的备份文件类型，备份集就是备份片的逻辑组合。一般一个通道生成一个备份集，如果设置了控制文件自动备份，则控制文件的备份文件单独生成一个备份集。控制文件的备份集以操作系统块作为最小单位，数据文件备份集以数据库块作为最小单位，所以它们不能放在一个备份集合中。
通道：RMAN是通过与数据库服务器的会话建立连接，通道代表这个连接，它指定了备份或恢复数据库的备份集所在的设备，如磁盘或磁带。
映像复制：映像复制是数据库文件的操作系统文件的一个备份，就如使用操作系统的COPY指令备份的文件一样，一个数据文件生成一个映像文件副本，整个复制过程是RMAN进行数据块的复制过程，RMAN会检测每一个数据块是否出现损坏，不需要将表空间设置成为begin backup，镜像副本中包含使用过的数据块，也包含从未使用过的数据块。生成镜像副本的好处在于恢复速度相对备份集来说，更快一些。

show all；查看相关配置参数
using target database control file instead of recovery catalog
RMAN configuration parameters for database with db_unique_name ORCL are:
CONFIGURE RETENTION POLICY TO REDUNDANCY 1; # default
CONFIGURE BACKUP OPTIMIZATION OFF; # default
CONFIGURE DEFAULT DEVICE TYPE TO DISK; # default
CONFIGURE CONTROLFILE AUTOBACKUP OFF; # default
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '%F'; # default
CONFIGURE DEVICE TYPE DISK PARALLELISM 1 BACKUP TYPE TO BACKUPSET; # default
CONFIGURE DATAFILE BACKUP COPIES FOR DEVICE TYPE DISK TO 1; # default
CONFIGURE ARCHIVELOG BACKUP COPIES FOR DEVICE TYPE DISK TO 1; # default
CONFIGURE MAXSETSIZE TO UNLIMITED; # default
CONFIGURE ENCRYPTION FOR DATABASE OFF; # default
CONFIGURE ENCRYPTION ALGORITHM 'AES128'; # default
CONFIGURE COMPRESSION ALGORITHM 'BASIC' AS OF RELEASE 'DEFAULT' OPTIMIZE FOR LOAD TRUE ; # default
CONFIGURE ARCHIVELOG DELETION POLICY TO NONE; # default
CONFIGURE SNAPSHOT CONTROLFILE NAME TO '/home/oracle/product/11.2.0/db_1/dbs/snapcf_orcl.f'; # default
```

##### 5、脱机备份

```
启动数据库到mount状态
backup as compressed backupset database;
```

##### 6、联机备份

```
需指定db_recovery_file_dest参数值，并将恢复区大小设置的足够大。
6.1 备份整个数据库
设置数据库为归档模式
backup as compressed backupset database plus archivelog delete all input;
备份完成后将删除归档目录下的归档文件。
在备份整个数据库时，其实就是备份了数据文件，其中包含了当前的控制文件和参数文件。而重做日志文件或归档日志文件不是联机状态数据库全备份的内容，所以使用联机热备份的数据库在数据恢复时需要recover数据库，即将联机备份开始到故障点之间的所有提交的数据重新写入数据文件。
可以手工指定多个通道，并将数据文件分布到不同的通道。

6.2 备份一个表空间
backup tablespace users;

6.3 备份一个数据文件
%c：备份片的副本数
%d：数据库名称
%D：位于该月的第几天
%M：位于该年的第几个月
%n：数据库名称，向右填补到最大19个字符
%u：一个19个字符的名称，代表备份集和创建时间
%p：该备份集的备份片号，从1开始到创建的文件数
%U：一个唯一的名字u_%p_%c
%s：备份集的编号
%t；备份集的时间戳
%T：年月日格式（YYYY-MM-DD）
backup as backupset datafile 1 format '/u01/backup/datafile_1_%U';

6.4 备份控制文件
backup current controlfile;

6.5 rman备份坏块处理方式
rman默认检查数据库是否物理损坏，加快速度关闭选项
backup nochecksum tablespace users tag='weekly_backup';
rman默认不会检查数据快是否逻辑损坏，backup可以启用逻辑损坏检查。
backup check logical tablespace users;
RMAN进行备份时，只要发现新的坏块，就立即停止备份。如果发现的坏块是上次已经发现的，则继续备份。我们可以设置maxcorrupt参数来通知RMAN，只有当发现的坏块个数超过指定的数量时，才停止备份。
这是一个迫不得已才使用的参数，尽量不要使用。
RMAN>run{
2>set maxcorrupt for datafile 2,4 to 10;
3>backup database;
4>}
数据文件2、4出现的新的坏块超过10的时候则停止备份。显然我们不希望出现坏块的情况，此时最后使用以前的RMAN的备份恢复这个坏块，修复后再备份该数据文件。
```

##### 7、增量备份

```
级别0的增量备份和级别1的增量备份。其中级别0的增量备份与全库备份相同。而级别1备份执行的是差异备份，即对级别0备份后变化的数据做备份。显然级别0备份是级别1备份的数据基础。
级别0备份
backup incremental level 0 database;
一级差异备份
差异备份是默认的备份方式，在备份时需要使用DIFFERENTIAL关键字，它是将备份上一次进行的同级或者低级备份以来所有变化的数据块。 
backup incremental level 1 database；
一级累计备份
使用累积备份时需要使用CUMULATIVE 关键字，它将备份上次低级备以来所有的数据块
backup incremental level 1 cumulative database；
```

##### 8、快速增量备份

```
避免扫描整个数据文件中变化的数据，将发生变化的数据块的位置记录在一个更改跟踪文件中，启动块跟踪特性后，CTWR进程将变化位置写入块跟踪文件。
启动块跟踪特性
alter database enable block change tracing using file '../chtrack.log';
如果该文件损坏或丢失则数据库无法启动，需要关闭该特性
查看是否启动该特性
select filename,status,bytes from vsblock change tracking
重命名或更改跟踪文件位置，需要到mount状态下
alter database rename file
关闭特性
alter database disable block change tracing；
```

##### 9、在映像副本上应用增量备份

```
·周日生成了一个镜像副本。
·周一进行增量备份，然后将产生的增量备份应用到周日所做的镜像副本上，这时周日的镜像副本中就包含了周一的数据，从而体现了最新的状态。
·周二的增量备份再应用到镜像副本上，以此类推。
对镜像副本应用增量备份的最大的好处在于加快恢复速度。
对镜像副本应用增量备份
RMAN>run{
2>backup incremental level 1 for recover of copy with tag incr_copy backup!
database; 
3>recover copy of database with tag,incr_copy backup';
4>}
查询副本
list copy
```

##### 10、创建和维护恢复目录

```
恢复目录保存了rman信息库的信息，包含备份集或映像复制，表空间和数据文件以及rman配置信息
10.1 创建恢复目录表空间
10.2 创建恢复目录用户
create user rcat_owner identified by oracle default tablespace rcat_tbs temporary tablespace temp;
alter user rcat_owner quto unlimited on rcat_tbs;
grant recovery_catalog_owner to rcat_owner;
```


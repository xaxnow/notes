## 主机名设置
```shell
# 添加IP和主机名或域名
vim /etc/hosts

# 修改主机名，并重启
hostname hn

```
## 1.依赖包安装
```shell 
yum -y install binutils compat-libstdc++ elfutils-libelf elfutils-libelf-devel \
gcc gcc-c++ glibc g1ibc-common glibc-headers libaio-devel 1ibaio libqcc libstdc++ \
libstdc++-devel make numact1 pdksh sysstat unixODBC unixODBC-devel compat-libcap1 ksh smartmontools unzip
#关闭防火墙和selinux
firewall-cmd add-port
```
## 2.添加用户和组
```
groupadd oinstall
groupadd dba
useradd -g dba -G oinstall -m oracle
passwd oracle
```
## 3.配置内核参数
```shell
#编辑/etc/sysctl.conf,添加
fs.aio-max-nr = 1048576
fs.file-max = 6815744
#最少为kernel.shmmax/4096,Oracle推荐2097152 
kernel.shmall = 2097152
#该值要小于共享内存的值
kernel.shmmax = 955037696
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max  = 41944304
net.core.wmem_default = 262144
net.core.wmem_max = 1048586
#使参数生效
sysctl -p
参数详解见末尾
```
## 4.修改用户资源限制
```shell
#打开的最大文件描述符nofile 65536
#单个用户可获得的最大进程数nproc 16384
#进程堆栈区的最大尺寸stack 10240

#在文件/etc/security/limits.conf中增加如下参数设置。
oracle soft nproc 2047
oracle hard nproc 16384
oracle soft nofile 1024
oracle hard nofile 65536
oracle soft stack 10240 
oracle hard stack 32768 
oracle hard memlock 134217728  
oracle soft memlock 134217728
#在文件/etc/pam.d/login中增加如下内容。
session required pam_limits.so
```
## 5.创建安装目录
```
mkdir -p /u01/app/oracle /u01/app/oraInventory /u01/app/oracle/oradata /u01/app/oracle/fast_recovery_area /u01/app/oracle/product/11.2.0/db_1
chown -R oracle:oinstall /u01/app/oracle /u01/app/oraInventory /u01/app/oracle/oradata /u01/app/oracle/fast_recovery_area /u01/app/oracle/product/11.2.0/db_1
chmod -R 775 /u01/app/oracle /u01/app/oraInventory /u01/app/oracle/oradata /u01/app/oracle/fast_recovery_area /u01/app/oracle/product/11.2.0/db_1
```
## 6.创建oraInst.loc文件
```
vim /etc/oraInst.loc
inventory_loc=/u01/app/oraInventory
inst_group=oinstall

chown oracle:oinstall /etc/oraInst.loc
chmod 644 /etc/oraInst.loc
```
## 7.上传解压

## 8.设置Oracle用户环境
```
vim .bash_profile
export LANG=en_US.UTF-8
export NLS_DATE_FORMAT='YYYY-MM-DD HH24:MI:SS'
export NLS_LANG="SIMPLIFIED CHINESE_CHINA.AL32UTF8" #客户端字符集
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
export ORACLE_SID=orcl
export PATH=$ORACLE_HOME/bin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
alias sqlplus='rlwrap sqlplus'

source .bash_profile
```
## 9.配置应答文件
```
cd database/response
ll  三个以.rsp结尾的文件,分别用于db安装,监听创建,数据库创建
cp ./response/db_install.rsp inst.rsp  注意文件位置
vim inst.rsp
DECLINE_SECURITY_UPDATES=true  这一项必须设置为true
```
## 10.Oracle用户下安装
```
./runInstaller -h  帮助
注意inst.rsp文件位置,要使用绝对路径
./runInstaller -silent -ignoreSysPrereqs -showProgress -responseFile pwd目录/inst.rsp
```
## 11.root用户执行脚本

## 12.报错
```
读安装日志
cat /u01/app/oracle/product/11.2.0/db_1/sysman/lib/ins_emagent.mk
```
## 13.创建监听
```
netca -silent -responsefile /u01/database/response/netca.rsp
```
## 14.创建数据库
```
修改dbca.rsp 根据帮助选择创建选项
dbca -silent -createDatabase -cloneTemplate -characterSet AL32UTF8 -responseFile /u01/database/response/dbca.rsp -gdbname orcl -sid orcl -sysPassword sys -systemPassword sys
```
## 15.配置自启动
```
将下面两个文件的$ORACLE_HOME_LISTENER=$1,将$1替换为$ORACLE_HOME
vim /u01/app/oracle/product/11.2.0/db_1/bin/dbstart
vim /u01/app/oracle/product/11.2.0/db_1/bin/dbshut

配置oratab
vim /etc/oratab
找到orcl:/u01/app/oracle/product/11.2.0/db_1:N，改为orcl:/u01/app/oracle/product/11.2.0/db_1:Y

配置rc.local
sudo vim /etc/rc.d/rc.local
添加
su oracle -lc "/u01/app/oracle/product/11.2.0/db_1/bin/lsnrctl start"
su oracle -lc /u01/app/oracle/product/11.2.0/db_1/bin/dbstart

增加权限
sudo chmod +x /etc/rc.d/rc.local
```
## 16.修改参数(一些容易造成问题的参数)
```
修改用户密码不过期:
alter profile default limit PASSWORD_LIFE_TIME unlimited;
创建用户并指定默认表空间:
create user test identified by test default tablespace test;
审计(重启):
alter system set audit_trail=none scope=spfile;
控制文件设置(归档保留时间长需要修改以保证控制文件能记录更多的记录,否则会被挤出去):
alter system set control_file_record_keep_time=30;
alter system set db_recovery_file_dest_size=...;
alter system set db_recovery_file_dest=''
```

## 参数详解
```shell
fs.aio-max-nr：

此参数限制并发未完成的请求，应该设置避免I/O子系统故障。

fs.file-max：

该参数决定了系统中所允许的文件句柄最大数目，文件句柄设置代表linux系统中可以打开的文件的数量。

kernel.shmall：

该参数控制可以使用的共享内存的总页数。Linux共享内存页大小为4KB,共享内存段的大小都是共享内存页大小的整数倍。一个共享内存段的最大大小是16G，那么需要共享内存页数是16GB/4KB=16777216KB /4KB=4194304（页），也就是64Bit系统下16GB物理内存，设置kernel.shmall = 4194304才符合要求.

kernel.shmmax：

是核心参数中最重要的参数之一，用于定义单个共享内存段的最大值。设置应该足够大，设置的过低可能会导致需要创建多个共享内存段，这样可能导致系统性能的下降。至于导致系统下降的主要原因为在实例启动以及ServerProcess创建的时候，多个小的共享内存段可能会导致当时轻微的系统性能的降低(在启动的时候需要去创建多个虚拟地址段，在进程创建的时候要让进程对多个段进行“识别”，会有一些影响)，但是其他时候都不会有影响。

官方建议值：

32位linux系统：可取最大值为4GB（4294967296bytes）-1byte，即4294967295。建议值为多于内存的一半，所以如果是32为系统，一般可取值为4294967295。

64位linux系统：可取的最大值为物理内存值-1byte，建议值为多于物理内存的一半，例如，如果为12GB物理内存，可取12*1024*1024*1024-1=12884901887。

kernel.shmmni：

该参数是共享内存段的最大数量。shmmni缺省值4096，一般肯定是够用了。

kernel.sem：

以kernel.sem = 250 32000 100 128为例：

   250是参数semmsl的值，表示一个信号量集合中能够包含的信号量最大数目。

   32000是参数semmns的值，表示系统内可允许的信号量最大数目。

    100是参数semopm的值，表示单个semopm()调用在一个信号量集合上可以执行的操作数量。

    128是参数semmni的值，表示系统信号量集合总数。

net.ipv4.ip_local_port_range：

表示应用程序可使用的IPv4端口范围。

net.core.rmem_default：

表示套接字接收缓冲区大小的缺省值。

net.core.rmem_max：

表示套接字接收缓冲区大小的最大值。

net.core.wmem_default：

表示套接字发送缓冲区大小的缺省值。

net.core.wmem_max：

表示套接字发送缓冲区大小的最大值。
```
## 报错
```
1.虚拟机一般都有
oracle用户编辑
vim /u01/app/oracle/product/11.2.0/db_1/sysman/lib/ins_emagent.mk
$(MK_EMAGENT_NMECTL)
替换为
$(MK_EMAGENT_NMECTL) -lnnz11

/dev/shm tmpfs tmpfs defaults,size=10G 0 0
mount -o remount /dev/shm
2.设置DISPALY
#root用户
export DISPALY=ip:0.0
xhost +
#远程到Oracle用户
ssh -Y oracle@192.168.31.47
xhost +
```
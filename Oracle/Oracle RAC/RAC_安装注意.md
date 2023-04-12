## Oracle高可用产品
```
1.Oracle RAC
2.Oracle Restart
3.Oracle Data Guard
4.Advanced Replication
5.Oracle Streams
6.Oracle Flashback
7.Oracle ASM
8.Recovery Manager
9.LogMiner
```
## RAC名词
```
1.OCR:Oracle Cluster Registry
2.voting disk
3.磁盘裸设备:11.2版本开始取消对磁盘裸设备支持
4.磁盘块设备
5.ASM实例和ASM磁盘组(共享存储)
6.virtual ip,private ip,public ip,scan ip
7.ACFS(ASM CLUSTER FILE SYSTEM)
```
## 注意事项
```
1.软硬件要求
    见目录图片
2.存储
    一般而言,Grid Infrastructure和Oracle软件都安装在本地磁盘,而节点间的共享文件则安装在外部共享存储上.
    2.1.NFS:配置NFS服务,设置一个共享目录,然后将这个目录mount到每个节点名称相同目录下,并保证软件安装者有读写权限
    2.2.OCFS(oralce cluster file system):每个节点安装OCFS,然后在外部存储设备安装这一文件系统并mount到每个节点同一目录,软件安装者具有读写权限
    2.3.ASM:选择ASM磁盘组要包含的磁盘,且软件安装者对这些磁盘有读写权限.安装Grid Infrastructure时将创建ASM实例并创建一个ASM磁盘组
    对于低于11.2版本的使用磁盘裸设备无疑是非常合适的
3.网络
    公共网络必须使用节点相同名称的网卡,且属于同一子网.私有网络也应尽量符合这一要求,且与公共网络子网不同
    RAC集群IP地址分配方法:
    1.DHCP
    2.手动(推荐)
    IP地址名称解析:
    1./etc/hosts文件
    2.DNS服务器
    3.Oracle GNS服务
    推荐IP地址解析由/etc/hosts文件完成,SCAN的名称解析由DNS或GNS完成
4.时钟
    RAC中节点时钟是同步的
    1.操作系统NTP服务
    2.Oracle CTSS服务(需关闭NTP)
```
## root用户操作
```
创建用户和组,配置内核参数,配置存储设备,配置网络,安装必要软件及创建必要目录,指定目录权限
```
### 1.操作系统配置
```
1.检查系统软硬件
grep MemTotal /proc/meminfo
grep SwapTotal /proc/meminfo
df -g
uname -a 内核版本及位数
rpm -q setarch glibc 所需软件是否安装
rpm -ivh ... 安装必要软件

2.创建用户及组,并指定口令
groupadd -g 500 oinstall
groupadd -g 501 dba
groupadd -g 502 asmdba
groupadd -g 503 asmadmin
groupadd -g 504 o
useradd -u 600 -g oinstall -G dba,asmdba oracle
passwd oracle
useradd -u 601 -g oinstall -G asmdba,asmadmin grid
passwd grid

3.内核参数修改
cat >> /etc/sysctl.conf << EOF
fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.shmall = 2097152
#该值要小于共享内存的值
kernel.shmmax = 68719476736
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max  = 41944304
net.core.wmem_default = 262144
net.core.wmem_max = 1048586
EOF

sysctl -p

4.shell资源限制
cat >> /etc/security/limits.conf <<EOF
grid soft nofile 1024
grid hard nofile 65536
grid soft nproc 2048
grid hard nproc 16384
grid soft stack 10240
grid hard stack	32768
oracle soft	nofile 1024
oracle hard	nofile 65536
oracle soft	nproc 2048
oracle hard	nproc 16384
oracle soft	stack 10240
oracle hard	stack 32768
EOF

5.指定一个可加载模块
cat >> /etc/pam.d/login <<EOF
session required /lib/security/pam_limits.so
EOF
```
### 2.存储设备配置
```
    一般软件的安装使用每个节点本地存储,而OCR,voting disk以及数据库中的文件放在外部共享存储.
1.创建必要目录及指定权限
mkdir -p /u01/app
mkdir /u01/app/base
mkdir /u01/app/grid
mkdir /u01/app/oracle
chown grid:oinstall /u01/app/grid
chown oracle:oinstall /u01/app/oracle
chmod -R g+w /u01

2.共享存储配置(raw,udev,multipath,asmlib)
    1.任一节点fdisk/gdisk创建分区, 其他节点partprobe /dev/sda同步分区信息

    虚拟机创建共享存储:
    vmware-vdiskmanager.exe -c -s 40GB -a lsilogic -t 2 D:\VMware\ShareDisk\myRac.vmdk

    虚拟机:添加"硬盘"--"使用现有虚拟磁盘"--"..."
    选中刚添加的硬盘:"高级"--"独立,永久"

3.ASM配置
    1.11.2之前的版本,以及centos7之前版本,编辑/etc/udev/rule.d/60-raw.rules,按如下指定裸设备文件
    ACTION=="add",KERNEL=="sda1",RUN+="/bin/raw /dev/raw/raw1 %N"
    ACTION=="add",ENV{MAJOR}=="8",ENV{MINOR}=="17",RUN+="/bin/raw /dev/raw/raw1 %M %m"
    --raw /dev/raw/raw3 /dev/sdd1 查看major
    KERNEL=="raw1",OWNER="grid" GROUP="asmadmin",MODE="0660"
    在系统产生裸设备文件:/sbin/start_udev
    查看结果:raw -qa,ll /dev/raw
```
### 3.网络配置
## Oracle用户操作
### 1.环境变量
```
ORACLE_BASE=/u01/app/base
ORACLE_HOME=/u01/app/grid
DISPLAY=127.0.0.1:0.0
export PATH=$ORACLEBASE:$ORACLE_HOME/bin:$PATH
```
### 2.ssh配置互信(Oracle,grid)
```
1.手工配置对等关系
cd /home/grid/
rsa密钥
ssh-keygen -t rsa
dsa密钥
ssh-keygen -t dsa

touch ~/.ssh/authorized_keys
cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
scp ~/.ssh/authorized_keys  rac2:/home/grid/.ssh/authorized_keys

exec ssh-agent $SHELL
ssh-add
ssh rac2 date 测试对等关系
ssh rac1 date 与自己建立对等
2.Oracle RAC自动配置对等关系
```
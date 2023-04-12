## 注意
```shell
#swap交换分区要和物理内存一样大 /tmp要大
systemctl stop firewalld
vim /etc/sysconfig/selinux
#停止NetworkManage
#centos 7安装遇到ohasd failed to start 先要运行脚本才能启动配好的服务(之前安装过可能需要重启服务)

touch /usr/lib/systemd/system/ohas.service
chmod 777 /usr/lib/systemd/system/ohas.service
vim /usr/lib/systemd/system/ohas.service

#添加
[Unit]
Description=Oracle High Availability Services
After=syslog.target

[Service]
ExecStart=/etc/init.d/init.ohasd run >/dev/null 2>&1 Type=simple
Restart=always

[Install]
WantedBy=multi-user.target

systemctl daemon-reload
systemctl enable ohas.service
systemctl start ohas.service
systemctl status ohas.service

#重新运行脚本root.sh
```
## 1.创建用户和组
```
groupadd -g 1000 oinstall
groupadd -g 1031 dba
groupadd -g 1020 asmadmin
groupadd -g 1022 asmoper
groupadd -g 1021 asmdba
useradd -u 1100 -g oinstall -G dba,asmdba,asmadmin,asmoper grid
useradd -u 1101 -g oinstall -G dba,asmdba oracle
passwd oracle/grid

grid\oracle 用户umsak022
```
## 2.修改/etc/hosts文件
```shell
/etc/hostname reboot

#public IP,对应第一块网卡,各节点网卡名要一致,需要配置dns
192.168.254.11 rac1
192.168.254.12 rac2
#private IP,对应第二块网卡，各节点网卡名要一致，不需要dns
10.0.0.11 rac1-priv
10.0.0.12 rac2-priv
#virtual IP,与public IP在一个网段
192.168.254.101 rac1-vip
192.168.254.102 rac2-vip
#scan IP,与virtual IP在同一个网段,安装前不能ping通，客户端访问应使用scan IP
#Oracle强烈建议您不要在hosts文件中配置SCAN VIP地址。对SCAN VIP使用DNS解析。
#如果使用hosts文件解析SCAN，那么您将只能解析为一个IP地址，并且只有一个SCAN地址。
192.168.254.201 scan
```
## 3.配置内核参数和Oracle、grid用户的shell资源限制
```
# /etc/sysctl.conf末尾添加

#fs.file-max=512*进程数

cat >> /etc/sysctl.conf << EOF
fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.shmmax = 955037696
kernel.shmall = 2097152
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048586
EOF

#sysctl -p 生效

#/etc/security/limits.conf末尾添加

cat >> /etc/security/limits.conf <<EOF
grid soft nofile 1024
grid hard nofile 65536
grid soft nproc 2048
grid hard nproc 16384
grid soft stack 10240
grid hard stack 32768
oracle soft nofile 1024
oracle hard nofile 65536
oracle soft nproc 2048
oracle hard nproc 16384
oracle soft stack 10240
oracle hard stack 32768
EOF

#/etc/pam.d/login添加
cat >> /etc/pam.d/login <<EOF
session required pam_limits.so
EOF
```
## 4.为GI和数据库软件创建相关路径
### 4.1 Inventory路径
```
mkdir -p /u01/app/oraInventory
chown -R grid:oinstall /u01/app/oraInventory
chmod -R 775 /u01/app/oraInventory
```
### 4.2 GI主目录
```
mkdir -p /u01/app/11.2.0/grid
chown -R grid:oinstall /u01/app/11.2.0/grid
chmod -R 775 /u01/app/11.2.0/grid
mkdir /u01/app/grid
chown -R grid:oinstall /u01/app/grid
chmod -R 755 /u01/app/grid
```
### 4.3 创建数据库主目录
```
mkdir -p /u01/app/oracle
chown -R oracle:oinstall /u01/app/oracle
chmod -R 775 /u01/app/oracle
```
### 4.4 创建数据软件主目录
```
mkdir -p /u01/app/oracle/product/11.2.0/db_1
chown -R oracle:oinstall /u01/app/oracle/product/11.2.0/db_1
chmod -R 775 /u01/app/oracle/product/11.2.0/db_1
```
### 4.5 修改grid、Oracle用户 ~/.bash_profile文件
```
grid:
export ORACLE_SID=+ASM1/+ASM2
export ORACLE_BASE=/u01/app/grid
export ORACLE_HOME=/u01/app/11.2.0/grid
export PATH=$ORACLE_HOME/bin:$PATH
alias sqlplus='rlwrap sqlplus'

oracle:
export ORACLE_SID=racdb1/racdb2(基于管理员管理) racdb_1/racdb_2(基于策略管理)
export ORACLE_UNQNAME=racdb
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
export PATH=$ORACLE_HOME/bin:$PATH
alias sqlplus='rlwrap sqlplus'
```
## 5.rpm包安装
```shell
#yum源配置:略

yum install -y compat-libstdc++ pdksh elfutils-libelf-devel elfutils-libelf gcc gcc-c++ glibc glibc-common \
glibc-devel glibc-headers ksh libaio libaio-devel libgcc libstdc++-devel make sysstat unixODBC unixODBC-devel

#一般没compat-libstdc++ pdksh cvuqdisk这些包,报错则用rpm -Uvh --nodeps --force 安装
#下载https://rpmfind.net/linux/RPM/index.html

#ASM软件
rpm -ivh --nodeps --force kmod-oracleasm(注意内核版本)\oracleasmlib\oracleasm-support\cvuqdisk
```

## 6.ssh互信,oracle和grid用户
```
su - grid
ra1,rac2都要执行:
ssh-keygen -t rsa
ssh-keygen -t dsa
Rac1:cat .ssh/id_rsa.pub >> .ssh/authorized_keys
Rac1:cat .ssh/id_dsa.pub >> .ssh/authorized_keys
ssh rac2 cat .ssh/id_rsa.pub >> .ssh/authorized_keys
ssh rac2 cat .ssh/id_dsa.pub >> .ssh/authorized_keys
scp .ssh/authorized_keys rac2:~/.ssh

在每个节点的grid用户
ssh rac1 date
ssh rac2 date
```
## 7.1.asmlib方式创建共享磁盘
`Voting file 和OCR是奇数个`
```shell

oracleasmlib-2.0.12-1.el7.x86_64
kmod-oracleasm-2.0.8-21.el7.centos.x86_64
oracleasm-support-2.1.11-2.el7.x86_64
CentOS Linux release 7.5.1804 (Core)


oracleasm configure -i
Default user to own the driver interface []: grid
Default group to own the driver interface []: asmadmin
Start Oracle ASM library driver on boot (y/n) [n]: y
Scan for Oracle ASM disks on boot (y/n) [y]: y
oracleasm status
oracleasm init
df -ha | grep oracle
lsmod | grep oracleasm
lsblk

#装grid时创建的是ocr,voting disk
fdisk /dev/sdb
Command (m for help): n
Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): p                                  
Partition number (1-4, default 1): 
First sector (2048-16171007, default 2048): 
Using default value 2048
Last sector, +sectors or +size{K,M,G} (2048-16171007, default 16171007): +1G

#重复
oracleasm createdisk vol1 /dev/sdb1
oracleasm scandisks
oracleasm listdisks
#安装发现不了需要重启
#其他节点scandisks
```
## 7.2.udev绑定
```
udevadm info -a -p /sys/block/sdc/sdc1 
根据KERNEL=="sdc1" ATTRS{size}=="614400"
向/etc/udev/rules.d/99-oracle-asmdevices.rules添加
KERNEL=="sdh1",SYSFS{size}=="614368",NAME="asm-diskh",OWNER="grid",GROUP="asmadmin",MODE="0660"

ll /dev/asm-disk*
```
## 8.校验环境
```
./runcluvfy.sh stage -pre crsinst -n rac1,rac2 -fixup -verbose | grep failed
```
## 9.安装 
```shell
su - root
xhost +
ssh -X grid@rac1 
unzip ...
cd ...
./runInstaller.sh
#oracleasm方式设备位置:oracleasm status
#注意
#/etc/resolv.conf 检查失败,未配置dns,可忽略
ntp失败忽略
udev方式报device checks for ASM 忽略

安装在Adding Clusterware entries to inittab卡住,
1.清除配置
/u01/app/11.2.0/grid/crs/install/roothas.pl -deconfig -force -verbose
2.root快速执行,执行完取消命令
dd if=/var/tmp/.oracle/npohasd of=/dev/null bs=1024 count=1

/u01/app/oraInventory/orainstRoot.sh
/u01/app/11.2.0/grid/root.sh

#INS-20802:未配置dns,走的是/etc/hosts,可忽略
#INS-32091:可忽略
#clock synchronization failed忽略
#single client access name ping通可忽略

#失败卸载
卸载
删除/etc/ora* /u01/app /usr/local/bin/*
```
## 10.脚本执行
```
#检查是否online  
/u01/app/11.2.0/grid/bin/crs_stat -t
```
## 11.asm\监听创建
```shell
#安装grid infustruncure时的是ocr和vf盘,可以根据需要创建flash area,redo log,oradata等

su- grid 
asmca

#监听一般跟随gird安装自动创建好
```
## 12.各节点数据库软件安装及数据库创建
```shell
#第四步若发现不了节点 执行下列脚本即可
/u01/app/11.2.0/grid/oui/bin/runInstaller  -silent -ignoreSysPrereqs -updateNodeList  ORACLE_HOME="/u01/app/11.2.0/grid" LOCAL_NODE="rac1"  CLUSTER_NODES="{rac1,rac2}"  CRS=true

#安装节点报错,编辑此节点
vim /u01/app/oracle/product/11.2.0/db_1/sysman/lib/ins_emagent.mk
$(MK_EMAGENT_NMECTL)
#替换为
$(MK_EMAGENT_NMECTL) -lnnz11

dbca
``` 













1.共享存储,分别建议300M*3或者1个900M，建议多个实现冗余。
voting disk:管理集群成员资格并在网络出现故障时仲裁节点之间的集群所有权。 
OCR(oracle cluster registry)：保留有关群集中任何群集数据库的群集配置信息和配置信息。
OCR包含诸如哪些数据库实例在哪些节点上运行以及哪些服务在哪些数据库上运行等信息。OCR还存储有关Oracle Clusterware控制的进程的信息。

2.网卡2个
两台网卡对应的public、private IP网卡名称要相同,不能使用带‘_’的主机名->hostname

3.IP地址,可以选择对虚拟IP（VIP）使用网格命名服务（GNS）和动态主机配置协议DHCP(dynamic host configrution protocol)
GNS(grid naming service):网格命名服务是Oracle Database 11g第2版中的一项新功能，
它使用多播域名服务器mDNS(multicast Domain Name Server）使群集能够在群集中添加和删除节点时动态分配主机名和IP地址，
而无需额外的网络地址配置在域名服务器（DNS）中

#public IP
192.168.254.11 rac1.example.com rac1
192.168.254.12 rac2.example.com rac2
#private IP
10.0.0.11 rac1-priv.example.com rac1-priv
10.0.0.12 rac2-priv.example.com rac2-priv
#virtual IP,与public IP在一个网段
192.168.254.101 rac1-vip.example.com rac1-vip
192.168.254.102 rac2-vip.example.com rac2-vip
#scan IP,与virtual IP在同一个网段,安装前不能ping通，客户端访问应使用scan IP
#Oracle强烈建议您不要在hosts文件中配置SCAN VIP地址。对SCAN VIP使用DNS解析。
#如果使用hosts文件解析SCAN，那么您将只能解析为一个IP地址，并且只有一个SCAN地址。
192.168.254.201 rac-scan.example.com rac-scan
192.168.254.202 rac-scan.example.com rac-scan
192.168.254.203 rac-scan.example.com rac-scan

4.操作系统用户和组(e-h组是可选的)
a.oracle用户：拥有所有Oracle软件安装（包括集群的Oracle Grid Infrastructure）或仅拥有Oracle数据库软件安装
b.grid用户：仅拥有Oracle Grid Infrastructure以进行群集安装，该用户拥有Oracle Clusterware和Oracle自动存储管理二进制文件
c.oinstall组：适用于所有安装的Oracle Inventory组（通常）。Oracle Inventory组必须是Oracle软件安装所有者的主要组。
Oracle Inventory组的成员可以访问Oracle Inventory目录。此目录是服务器上所有Oracle软件安装的中央库存记录，以及每个安装的安装日志和跟踪文件。
d.dba组：授予管理Oracle数据库的SYSDBA权限以及管理Oracle Clusterware和Oracle ASM的SYSASM特权
e.asmadmin组：Oracle自动存储管理组，如果要为Oracle ASM和Oracle数据库管理员分别拥有管理权限组，请将此组创建为单独的组。OSASM组的成员可以使用SQL连接到Oracle ASM实例，
如SYSASM使用操作系统身份验证。该SYSASM权限允许安装和拆卸磁盘组和其他存储管理任务。SYSASM权限不提供对Oracle数据库实例的访问权限。如果您不创建单独的OSASM组
f.asmdba组：ASM数据库管理员组，用于Oracle ASM的OSDBA组的成员被授予对Oracle ASM管理的文件的读写访问权限。集群安装所有者和所有Oracle数据库软件所有者
（例如，oracle）的Oracle Grid Infrastructure 必须是该组的成员，并且对于需要访问由Oracle ASM管理的文件的数据库具有OSDBA成员资格的所有用户应该是ASBA组的OSDBA
g.oper组：OSOPER for Oracle数据库组，希望某些操作系统用户具有一组有限的数据库管理权限（该SYSOPER权限），请创建此组。OSDBA组的成员自动拥有该权限授予的所有SYSOPER权限。
h.asmoper组：Oracle ASM组的OSOPER，该组的成员被授予对SYSASM特权子集的访问权限，例如启动和停止Oracle ASM实例

#在每个节点创建用户和组
groupadd -g 1000 oinstall
groupadd -g 1001 dba
useradd -u 1100 –g oinstall -G dba -d /home/oracle -r oracle
passwd oracle

5.网络配置（dns/gns）

6.时间设置
a.ntp
b.ctts

7.内核参数配置

8.安装目录配置
Oracle中央库存目录（可以不建）: 
mkdir -p /u01/app/oraInventory
Grid主目录（不能是ORACLE_BASE子目录）：
mkdir -o /u01/app/grid  
chown -R Oracle：oinstall /u01/app/grid
ORACLE_BASE目录:
mkdir -p /u01/app/oracle 
chown -R oracle:oinstall /u01/app/oracle 
chmod -R 755 /u01/app/oracle
oracle主目录ORACLE_HOME（可以不建）：
mkdir -p /u01/app/oracle/product/11.2.0/db_1


9.共享存储配置
集群中的每个节点都需要外部共享磁盘来存储Oracle Clusterware（Oracle Cluster Registry和Voting Disk）文件以及Oracle Database文件

10.磁盘设备永久性
warning: oracleasmlib-2.0.12-1.el7.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID ec551f03: NOKEY
error: Failed dependencies:
	oracleasm >= 1.0.4 is needed by oracleasmlib-2.0.12-1.el7.x86_64


11..bashrc
export ORACLE_BASE=/u01/app/oracle 
export ORACLE_HOME=/u01/app/grid
dns
OCR

ntp 网络时间协议，未配置则使用ctss
ctss Oracle集群时间同步服务




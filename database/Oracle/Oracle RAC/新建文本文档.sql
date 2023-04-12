共享内存参数
打开文件描述符和UDP发送/接收参数
./runcluvfy.sh stage -pre crsinst -n node1，node2 -fixup -verbose
xhost + RemoteHost
ssh -Y RemoteHost
grid、oracle用户
oinstall、dba、asmadmin、asmdba、oper、asmoper
groupadd -g 1000 oinstall
groupadd -g 1031 dba
groupadd -g 1020 asmadmin
groupadd -g 1022 asmoper
groupadd -g 1021 asmdba
useradd -u 1100 -g oinstall -G dba,asmdba,asmadmin,asmoper grid -g 主组 -G辅助组
useradd -u 1101 -g oinstall -G dba,asmdba oracle -u uid,可选的
usermod -g oinstall -G dba，asmdba oracle 修改

mkdir -p /u01/app/grid
mkdir -p /u01/app/11.2.0/grid
mkdir -p /u01/app/oracle
chown -R grid:oinstall /u01/app/grid
chown -R grid:oinstall /u01/app/11.2.0/grid
chown -R oracle:oinstall /u01/app/oracle
chmod -R 775 /u01

GNS:public IP为static, virtual IP 为DHCP,要分配3个SCAN IP，private IP为DHCP或static Oracle不推荐此方式

网络时间协议配置,如果配置了ntpd服务，csstd将以观察者模式运行，否则以活动模式
删除ntp	
systemctl stop ntpd 
systemctl disabled ntpd
rm /etc/ntp.conf
rm /var/run/ntpd.pid

配置ntp
vim /etc/sysconfig/ntpd centos7 为/etc/sysconfig/ntpdate
OPTIONS="-x -u ntp:ntp -p /var/run/ntpd.pid"
systemctl restart ntpd

csst
crsctl check ctss 

软件包
cvuqdisk	发现共享存储

ssh授信对等,
su - grid
ra1,rac2都要执行:
ssh-keygen -t rsa
ssh-keygen -t dsa
scp grid@rac2/home/grid/.ssh/id_dsa.pub grid@rac2:/home/grid/.ssh/id
cat ~/.ssh/id_dsa.pub >> authorized_keys
cat ~/.ssh/id >> authorized_keys
scp grid@rac1:/home/grid/.ssh/authorized_keys grid@rac2:/home/grid/.ssh/
在每个节点的grid用户
ssh rac1
ssh rac2

systemctl stop firewalld


/etc/ssh/sshd_config 
LoginGraceTime 0 超时等待无

安装环境
umask 022
xhost + localhost su -grid 本地
export DISPLAY=ip:0.0 远程
export DISPLAY=node1:0 如果您在远程终端上，并且本地节点只有一个可视（这是典型的），则使用以下语法设置DISPLAY环境变量
/tmp 大于1G
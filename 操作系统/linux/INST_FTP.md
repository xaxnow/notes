### 1.安装vsftp
```
rpm -ivh vsftp...
```
### 2.root建用户
```
useradd test -d /home/test  --指定test用户主目录
passwd test
```
### 3.更改用户相应权限
```shell
#限定用户不能telnet只能ftp
usermod -s /sbin/nologin test
#用户test恢复正常
usermod -s /bin/bash test 
```
### 4.限定用户只能访问主目录
```shell
vim /etc/vsftp/csftp.config
chroot_list_enable=YES //限制访问自身目录
```
### 5.启动
```
关闭防火墙,selinux
systemctl start vsftpd
systemctl enable vsftpd
```
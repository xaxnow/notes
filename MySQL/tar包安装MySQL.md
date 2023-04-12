## 1.下载上传解压tar包
```
下载:选择Linux-Generic版本
上传:上传到/usr/local目录下
解压:tar -xvf mysql-8.0.17-linux-glibc2.12-x86_64.tar.xz
重命名:mv mysql-8.0.17-linux-glibc2.12-x86_64 mysql
卸载mariadb(会存在/etc/my.cnf,启动时会报错,安装percona_xtrabackup需重新安装):
rpm -qa | grep mariadb
rpm -e ...
```
## 2.创建用户组和数据目录
```
注意:若想在安装时修改datadir则要修改mysql/support-files/mysql.server中datadir变量,且要修改目录属主和属组为MySQL.
groupadd mysql
useradd mysql -g mysql -s /sbin/nologin
mkdir -p /usr/local/mysql/data
chown -R mysql:mysql /usr/local/mysql
```

## 3.安装数据库
```shell
#将MySQL命令加入环境变量
vim /etc/profile
export MYSQL_HOME=/usr/local/mysql
export PATH=$MYSQL_HOME/bin:$PATH

source /etc/profile
#初始化数据库目录
mysqld --initialize --user=mysql --datadir /usr/local/mysql/data
#将MySQL加入到服务自启动
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql
#启动服务
/etc/init.d/mysql start
#可以使用如下方式管理服务,但不能使用systemctl
service mysql [start/stop/restart]
#登录
mysql -u root -p 
#输入临时密码
#更改当前登录用户密码
alter user user() identified by 'root';
```
## 4.安装后修改数据目录及字符集
```
vim /etc/my.cnf

[mysqld]
datadir=/usr/local/mysql/data
[client]
port=3306
```
## 5.授予权限远程登录
```
5.7:
grant all privileges on *.* to 'root'@'%' identified by 'root'  with grant option;
flush privileges;立即生效
8.0:需先创建用户再授权
create user 'root'@'%' identified by 'mysql';
grant all privileges on *.* to 'root'@'%';
flush privileges;
```
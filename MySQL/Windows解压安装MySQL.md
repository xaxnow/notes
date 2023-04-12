### 1.下载解压
```
例如:D:\Program Files\mysql目录
```
### 2.添加配置文件
```
到basedir/bin下输入:mysql --help --verbose
找到如下说明(MySQL建议的配置文件位置,Linux为:mysql --help | grep my.cnf):
Default options are read from the following files in the given order:
C:\WINDOWS\my.ini C:\WINDOWS\my.cnf C:\my.ini C:\my.cnf D:\Program Files\mysql\my.ini D:\Program Files\mysql\my.cnf

选择任意一位置新建配置文件:如,D:\Program Files\mysql\my.cnf,和存放数据目录:D:\Program Files\mysql\data
在其中添加如下内容:
[mysqld]
basedir=D:\Program Files\mysql
datadir=D:\Program Files\mysql\data
port = 3306
```
### 3.初始化数据库
```
D:\Program Files\mysql\bin>mysqld --initialize --user=mysql --console
2019-10-28T11:42:06.596994Z 0 [System] [MY-013169] [Server] D:\Program Files\mysql\bin\mysqld.exe (mysqld 8.0.18) initializing of server in progress as process 6608
2019-10-28T11:42:21.663687Z 5 [Note] [MY-010454] [Server] A temporary password is generated for root@localhost: DgJewVfYv6.Q
```
### 4.将MySQL添加到系统服务
```
添加方式也可以根据帮助查看:略
D:\Program Files\mysql\bin>mysqld.exe --install MySql
Service successfully installed.

D:\Program Files\mysql\bin>net start MySql
MySql 服务正在启动 ..
MySql 服务已经启动成功。
```
### 5.使用临时密码登录并修改密码
```
D:\Program Files\mysql\bin>mysql -uroot -p
Enter password: ************
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8
Server version: 8.0.18

Copyright (c) 2000, 2019, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>alter user user() identified by 'root';
修改当前登录用户密码
```
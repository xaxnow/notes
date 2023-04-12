`因为centos不在官方支持的列表,ACFS 这个特性在安装 Grid 时也没有安装。尝试安装时，会提示 ”Not Supported”,所以不能使用ADVM和ACFS`
### 1.修改grid用户osds_acfslib.pm(所有节点)
```
vim $ORACLE_HOME/lib/osds_acfslib.pm
#找到
(($release =~ /^redhat-release/) ||        # straight RH
       ($release =~ /^enterprise-release/) ||    # Oracle Enterprise Linux
       ($release =~ /^oraclelinux-release/))) 

#在redhat下添加一行
($release =~ /^centos-release/) ||  #Centos
```
### 安装acfs，配置acfs和advm模块启动自动加载(所有节点)
```

```
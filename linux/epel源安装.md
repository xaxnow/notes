centos7
```
# wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
# rpm -ivh epel-release-7.noarch.rpm 
```
centos6
```
http://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
```
使用
```
yum repolist
yum --enablerepo=epel install perl-* -y
```
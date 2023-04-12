## 1.配置本地yum源或到挂载目录下找到vsftpd包安装
```
mount -o loop Cent* /mnt
rm -rf /etc/yum.repos.d/Cent*
touch /etc/yum.repos.d/cent.repo
cat <<EOF
[cent]
name=cent
baseurl=file:///mnt
enabled=1
gpgcheck=0
EOF

yum repolist
```
## 2.安装ftp
```
yum -y install vsftpd
systemctl start vsftpd
systenctl enable vsftpd
```

## 3.挂载ISO到ftp目录下
```shell
mount Cent* /var/ftp/pub/cent
#设置开机挂载
vim /etc/fstab
iso_location /var/ftp/pub/cent iso9660 defaults 0 0
```
## 4.其他服务器配置
```
rm -rf /etc/yum.repos.d/Cent*
touch /etc/yum.repos.d/cent.repo
cat <<EOF
[cent]
name=cent
baseurl=ftp://192.168.1.12/pub/cent
enabled=1
gpgcheck=0
EOF

yum repolist
```



1.rpm包安装
```shell
yum -y install bind bind-chroot
```
2.编辑/etc/named.conf主配置文件，改
```shell
listen-on port 53 { any; };
allow-query     { any; };
```

3.编辑/etc/named.rfc1912.zones文件，末尾添加
```shell
#正向解析
zone "example.com" IN{
        type master;
        file "example.com.zone";
        allow-update {none;};
};
#反向解析
zone "254.168.192.in-addr.arpa" IN{
        type master;
        file "192.168.254.arpa";
        allow-update {none;};
};
```
3.
```shell
cp -a /var/named/named.localhost /var/named/example.com.zone
#正向和方向解析名称要和上面的配置文件一直
vim /var/named/example.com.zone
$TTL 1D
@	IN SOA	example.com. root.example.com. (
					0	; serial
					1D	; refresh
					1H	; retry
					1W	; expire
					3H )	; minimum
	IN NS	dns.example.com.
dns IN A 192.168.254.11
rac1 IN A 192.168.254.11
rac2 IN A 192.168.254.12
rac-scan IN A 192.168.254.201

cp -a /var/named/named.loopback /var/named/192.168.254.arpa
$TTL 1D
@	IN SOA	example.com. root.example.com. (
					0	; serial
					1D	; refresh
					1H	; retry
					1W	; expire
					3H )	; minimum
	IN NS	dns.example.com.
dns IN	A	192.168.254.11
11 IN	PTR	rac1.example.com.
12 IN	PTR	rac2.example.com.
201 IN	PTR	rac-can.example.com.
```
4.下面的在所有节点操作
```
vim /etc/resolv.conf
nameserver 192.168.254.11
nmtui 设置dns地址
Avahi 是 zeroconf 协议的实现。它可以在没有 DNS 服务的局域网里发现基于 zeroconf 协议的设备和服务。它跟 mDNS 一样。
除非你有兼容的设备或使用 zeroconf 协议的服务，否则应该关闭它。我把它关闭
```
5.
```
systemctl restart named
```
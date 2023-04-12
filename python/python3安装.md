1.下载解压:略
2.安装编译所需的依赖包:
```shell
yum install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gcc make libffi-devel
```
3.切换到python解压目录:
```shell
./configure --prefix=/usr/local/python3
make -j50 && make install
```
4.添加软链:
```shell
ln -s /usr/local/python3/bin/python3.7 /usr/bin/python3.7
ln -s /usr/local/python3/bin/pip3.7 /usr/bin/pip3.7
```
5.测试是否成功
```shell
python3.7 -V
```

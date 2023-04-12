环境变量 $0 $$ $#(参数个数) $IFS(输入域分隔符) $PS2(二级提示符) $PS
参数变量 $1,$2... ,$\*(所有参数),$@
shift 位置参数变量左移,十个以上位置参数变量

break 跳出循环
continue 跳到下一次循环
: 空名令,相当于 true
source 和 . 不启用新的 shell，在当前 shell 中执行，设定的局部变量在执行完命令后仍然有效.在当前 bash 环境下读取并执行 FileName 中的命令
例:在在 shell.sh 中有变量 var1 . ./shell.sh 或 source ./shell.sh 执行后仍然可以打印变量 var,而./shell.sh 执行则无结果
eval 给变量额外加$,引用最后的变量结果
expr 将参数当作表达式求值,$(())
printf
常用转义字符
　\a 响铃(BEL) 007
　\b 退格(BS) 008
　\f 换页(FF) 012
　\n 换行(LF) 010
　\r 回车(CR) 013
　\t 水平制表(HT) 009
　\v 垂直制表(VT) 011
　\\ 反斜杠 092
　\? 问号字符 063
　\' 单引号字符 039
　\" 双引号字符 034
　\0 空字符(NULL) 000
　\ddd 任意字符 三位八进制
　\xhh 任意字符 二位十六进制
字符转换限定符(python 中的格式化字符串)
d 输出一个十进制数字
c 输出一个字符
s 输出一个字符串
% 输出一个%字符
printf "%s %d\t%s \n" "hi nihao" 15 ceshi
return 函数退出码
set 改变 shell 环境的运行参数
例:
set=`date`
echo $2

trap 接收到信号后采取的行动 trap -l
unset 删除变量和函数
find path options tests actions

命令执行
`` $()
算数运算:$(($x+1)) expr $x+1

参数扩展:如区分$i_tmp,${i}\_tmp
注意 param 是不带$符的
${param:-default} param 为空就 default
${#param}   给出param长度
${param%word} 从 param 尾部开始删除与 word 匹配的最小部分返回剩余部分
${param%%word}  从param尾部开始删除与word匹配的最长部分返回剩余部分
${param#word} 从 param 头部开始删除与 word 匹配的最小部分返回剩余部分
${param##word} 从 param 头部开始删除与 word 匹配的最长部分返回剩余部分

env
file 查看文件类型
less 比 more 可以前后移动
killall 通过进程名结束进程
type
lsof 列出被打开的文件的进程
sort 排序
命令列表 pwd ; ls ; cd /etc ; pwd ; cd ; pwd ; ls
进程列表 (pwd ; ls ; cd /etc ; pwd ; cd ; pwd ; ls)
export 设置环境变量，不加$
unset 删除环境变量

useradd
userdel -r
usermod 修改用户密码、账户失效时间、添加组等
chpasswd 从 stdin 大量修改密码

groupadd
groupmod
id username 查看用户所属组

umask 0022 第一个 0 粘着位(sticky bit) - 默认 666 d 默认 777
chmod
chown
chgrp

共享目录：
设置用户 ID（SUID）：当文件被用户使用时，程序会以文件属主的权限运行。
-rwsr--r-- chmod u+s filename
设置组 ID（SGID）：对文件来说，程序会以文件属组的权限运行；对目录来说，
目录中创建的新文件会以目录的默认属组作为默认属组，而不是用户的默认属组。
dr--rws---
粘着位(SBIT)：进程结束后文件还驻留（粘着）在内存中。

uname 系统内核
uptime 系统时间、负载
who 终端信息
whoami 当前用户
last 登录记录
sosreport 收集系统信息
tr 替换文件中的文本
wc 统计文件函数，字节数，单词数
stat 查看文件时间
文件时间
atime access 查看
ctime change 属性
mtime modify 内容
cut 提取列的信息 /etc/passwd
diff 比较两个文件
touch 更改文件时间属性
dd 备份复制
file 查看文件类型
tar z gzip jbzip2
curl
wget

exec 是用被执行的命令行替换掉当前的 shell 进程，且 exec 命令后的其他命令将不再执行。
例如在当前 shell 中执行 exec ls   表示执行 ls 这条命令来替换当前的 shell ，即为执行完后会退出当前 shell。
为了避免这个结果的影响，一般将 exec 命令放到一个 shell 脚本中，用主脚本调用这个脚本

eval

网卡配置
/etc/sysconfig/network-scripts/ifcfg-\*
nmtui 图形界面配置--5、6 是 setup
nm-connection-editor

iostat
netstat
vmstat

重定向:
输入输出 > >> < <<:从标准输入中读取，直到遇到分界符(即<<后的字符)停止
输出：标准信息 1> 1>>错误信息 2> 2>> 输入： <0
无论对错 &> &>>

文件系统写入方式
数据模式
有序模式
回写模式

tab 键 inst.gpt
操作文件系统
lsblk 列出所有磁盘列表
blkid 列出设备的 UUID universally unique identifier，文件系统类型
parted 列出磁盘的分区表类型与分区信息 对 gpt/mbr 分区
fdisk mbr 分区 gdisk gpt 分区 设备参数不能带数字，即针对的是设备分区而不是 partition
partprobe 更新 Linux 核心的分区表信息
mkfs.\* 创建文件系统
xfs_repair/fsck.ext4 不能检查/修复被挂载的文件系统，repair/目录进救援模式

mount
参数：在/etc/fstab 的权限中的重要参数
-o ：后面可以接一些挂载时额外加上的参数！比方说帐号、密码、读写权限等：
async, sync: 此文件系统是否使用同步写入 （sync） 或非同步 （async） 的
内存机制，请参考[文件系统运行方式](../Text/index.html#harddisk-filerun)。默认为 async。
atime,noatime: 是否修订文件的读取时间（atime）。为了性能，某些时刻可使用 noatime
ro, rw: 挂载文件系统成为只读（ro） 或可读写（rw）
auto, noauto: 允许此 filesystem 被以 mount -a 自动挂载（auto）
dev, nodev: 是否允许此 filesystem 上，可创建设备文件？ dev 为可允许
suid, nosuid: 是否允许此 filesystem 含有 suid/sgid 的文件格式？
exec, noexec: 是否允许此 filesystem 上拥有可执行 binary 文件？
user, nouser: 是否允许此 filesystem 让任何使用者执行 mount ？一般来说，
mount 仅有 root 可以进行，但下达 user 参数，则可让一般 user 也能够对此 partition 进行 mount 。
defaults: 默认值为：rw, suid, dev, exec, auto, nouser, and async
remount: 重新挂载，这在系统出错，或重新更新参数时，很有用！

特殊设备 loop 挂载(镜像文件不挂载就使用)
mount -o loop /centos.iso

swap 分区创建
fdisk/gdisk
partprobe
mkswap
swapon 设备 swapoff
/etc/fstab

tune2fs/dump2fs
/etc/fstab filesystem table（开机挂载）
UUID=b7e5e2e5-d6a3-4afd-a9cc-f741198a5d81 / xfs defaults 0 0
uuid/设备名 挂载目录 文件系统 文件系统参数 dump fsck
/etc/mtab table of mounted filesystem

LVM(logical volume manager)
gdisk/fdisk t 把系统识别码改成 8e
--pe physical extent 逻辑卷最小存储单位，LV 通过增大/缩小 pe 改变容量
pvcreate 创建物理卷 physical volume
vgcreate 卷组 volume group
lvcreate 逻辑卷
mkfs.\*
mount

resize2fs/xfs_growfs 逻辑卷路径 --更新文件系统

quota 磁盘配额

RAID （Redundant Arrays of Inexpensive Disks ）
mdadm 软件磁盘阵列
/etc/mdadm.conf 开机自动挂载

软件安装
Debian 和 Redhat
dpkg/rpm
apt-get/yum

共享内存相关:ipcs,ipcrm
IPC 管理 进程间通信:sysresv
信号量：

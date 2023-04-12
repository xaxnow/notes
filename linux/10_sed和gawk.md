# sed编辑器
```
sed options scripts file(scripts格式[寻址]命令[///],)
-n 只显示匹配的行
```
1.替换
```
sed -i 's/test/find/' data.txt		把data.txt中的test替换为find
替换标记 s/pattern/replacement/flags
数字  s/test/find/2	第二处替换
g	s/test/find/g		替换所有匹配的
p	打印匹配行
w file 	将替换的结果写到文件中
```
2.使用地址
```
数字方式的行寻址	sed '2,3s/dog/cat/' data1.txt
使用文本模式过滤器	sed '/Samantha/s/bash/csh/' /etc/passwd
执行多条命令
sed '2{
> s/fox/elephant/
> s/dog/cat/
> }' data1.txt
```
3.删除
```
'd'  '1d'  '2,3d'  模式匹配也能删除 '/test/d'
sed '/1/,/3/d' data6.txt	两个文本模式匹配,第一个打开,第二个关闭,如果文件又出现1则又打开,直到找到关闭模式
```
4.追加,删除,修改
```
sed '[address]command\文本' data.txt
插入	i	insert
追加	a	append
修改	c	change
```
5.转换
```
y	处理单个字符	
sed '[address]y/inchars/outchars/' data.txt
inchars 中的第一个字符会被转换为 outchars 中的第一个字符，
第二个字符会被转换成 outchars 中的第二个字符,长度不同会报错
```
6.打印 
```
p  打印匹配行
=  打印行号
l  列出行,用于常见的不可打印字符,如\t
```
7.写入文件  
```
[address]w filename
sed '1,2w test.txt' data6.txt
```
8.读取数据
```
[address]r filename
sed '3r data12.txt' data6.txt	将读取的文件写入到data6
```
# sed多行命令
```
举个例子，如果你正在数据中查找短语 Linux System Administrators Group ，它很有
可能出现在两行中，每行各包含其中一部分短语。如果用普通的sed编辑器命令来处理文本，就
不可能发现这种被分开的短语
 N ：将数据流中的下一行加进来创建一个多行组（multiline group）来处理。
 D ：删除多行组中的一行。
 P ：打印多行组中的一行。
```
```
next 
n   找到匹配的后移到下一行
N   将下一行添加到已有的文本后  sed 'N ; s/System.Administrator/Desktop User/' data3.txt
D   多行删除   sed 'N ; /System\nAdministrator/D' data4.txt
p   多行打印   sed -n 'N ; /System\nAdministrator/P' data3.txt
```
```
模式空间和保留空间

!  排除命令  sed -n '/header/!p' data2.txt
```
```
改变流
分支,排除一整块区间 b  [ address ]b [ label ]  address决定哪些数据触发命令b,而lable参数定义要跳转的位置
sed '{2,3b ; s/This is/Is this/ ; s/line./test?/}' data2.txt  如果不加3则默认 以$结尾
sed '{/first/b jump1 ; s/This is the/No jump on/
> :jump1
> s/This is the/Jump here on/}' data2.txt    匹配到first,则跳转执行jump1标签后的脚本
测试   t  [ address ]t [ label ]
匹配了走adress,不匹配走标签后的
```
```
模式替代
&   sed 's/cat/"&"/g' data.txt  为cat加"",&替代了cat
替代单独单词,&提取整个字符串,而有时只想提取字符串的一部分
sed编辑器用圆括号来定义替换模式中的子模式。你可以在替代模式中使用特殊字符来引用
每个子模式。替代字符由反斜线和数字组成。数字表明子模式的位置。sed编辑器会给第一个子
模式分配字符 \1 ，给第二个子模式分配字符 \2
echo "That furry cat is pretty" | sed 's/furry \(.at\)/\1/'
```


# gawk程序
```
支持结构化命令,如if,while等,单行使用多个命令要用;

gawk options program file
gawk '条件类型1{动作1}	条件类型2{动作2}' filename
```

1.数据字段变量
```
$0	整个文本行
$n	文本行中的第n个数据字段
```
2.字段分隔符变量
```
FIELDWIDTHS 由空格分隔的一列数字，定义了每个数据字段确切宽度
FS  输入字段分隔符
RS  输入记录分隔符
OFS 输出字段分隔符
ORS 输出记录分隔符
```
3.数据变量
```
ARGC    当前命令行参数个数
ARGIND  当前文件在 ARGV 中的位置
ARGV    包含命令行参数的数组
CONVFMT 数字的转换格式（参见 printf 语句），默认值为 %.6 g
ENVIRON 当前shell环境变量及其值组成的关联数组
ERRNO   当读取或关闭输入文件发生错误时的系统错误号
FILENAME    用作gawk输入数据的数据文件的文件名
FNR 当前数据文件中的数据行数
IGNORECASE  设成非零值时，忽略 gawk 命令中出现的字符串的字符大小写
NF  数据文件中的字段总数
NR  已处理的输入记录数
OFMT    数字的输出格式，默认值为 %.6 g
RLENGTH 由 match 函数所匹配的子字符串的长度
RSTART  由 match 函数所匹配的子字符串的起始位置
```
4.自定义变量
```
gawk 'BEGIN{x=4; x= x * 2 + 3; print x}'
在命令行给变量赋值
$ cat script1
BEGIN{FS=","}
{print $n}
$ gawk -f script1 n=2 data1
```
5.使用模式
```
正则表达式,使用时必须出现在控制程序脚本前
gawk 'BEGIN{FS=","} /11/{print $1}' data1
匹配操作符 ~,将正则表达式限定在记录的特定数据字段
gawk -F: '$1 ~ /rich/{print $1,$NF}' /etc/passwd
数学表达式
gawk -F: '$4 == 0{print $1}' /etc/passwd
```
6.结构化命令
```
if (condition) { ... } else { ... }
while (condition) { ... } #支持break和continue
do { ... } while (condition)
for (i=1;i<4;i++) { ... }
```
7.格式化打印
```
printf "format string", var1, var2 . . .
格式化制定符格式
%[modifier]control-letter
控制字母
c	将一个数作为ASCII字符显示
d	显示一个整数值
i	显示一个整数值（跟d一样）
e	用科学计数法显示一个数
f	显示一个浮点值
g	用科学计数法或浮点数显示（选择较短的格式）
o	显示一个八进制值
s	显示一个文本字符串
x	显示一个十六进制值
X	显示一个十六进制值，但用大写字母A~F
其他修饰符配合格式化制定符控制输出
width 输出字段最小字段值
prec 指定了浮点数中小数点后面位数，或者文本字符串中显示的最大字符数
- 采用左对齐
```
8.内置函数
```
数学函数:标准数学函数与按位操作数学函数
字符串函数
时间函数
```
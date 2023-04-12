```shell
#需要打印含'的语句,1.加双“”2.加转义字符\
echo " let's go "
echo let\'s go

#命令替换
# 命令替换会创建一个子shell来运行对应的命令。子shell（subshell）是由运行该脚本的shell
# 所创建出来的一个独立的子shell（child shell）。正因如此，由该子shell所执行命令是无法
# 使用脚本中所创建的变量的。
# 在命令行提示符下使用路径 ./ 运行命令的话，也会创建出子shell；要是运行命令的时候
# 不加入路径，就不会创建子shell。如果你使用的是内建的shell命令，并不会涉及子shell。
# 在命令行提示符下运行脚本时一定要留心！
test=$(date)
test=`date`

#单引号、双引号区别
#单引号---所见即所得
echo '$test'
#双引号---把双引号内的内容输出出来；如果内容中有命令，变量等，会先把变量，命令解析出结果，
# 然后在输出最终内容来。双引号内命令或变量的写法为`命令或变量`或$（命令或变量）。
echo "$test"

# 字段分隔符	IFS=‘，’，则分隔符为逗号
#通配符


#输入重定向，command < inoutfile
wc < test.txt
#内联输入重定向
command << EOF
data
EOF
#eof是结束符，即数据的开始和结尾文本标记必须一致

#数学运算
#不推荐
expr 1 + 2
#推荐$[1 + 2]
var = $[1 + 2]

#if 判断后的condition
#比较---数值、字符串、文件
#数值比较
$a -gt $b  a变量是否大于b变量  -lt小于 -ne不等于 -ge大于等于
#字符串比较	
-n 长度非0 -z 是否为0 = != < >
#文件比较
-d file	检查 file 是否存在并是一个目录
-e file	检查 file 是否存在
-f file	检查 file 是否存在并是一个文件
-r file	检查 file 是否存在并可读
-s file	检查 file 是否存在并非空
-w file	检查 file 是否存在并可写
-x file	检查 file 是否存在并可执行
-O file	检查 file 是否存在并属当前用户所有
-G file	检查 file 是否存在并且默认组与当前用户相同
file1 -nt file2	检查 file1 是否比 file2 新
file1 -ot file2	检查 file1 是否比 file2 旧
#复杂逻辑判断
-a 与
-o 或
!  非

#(())双括号高级数学运算
#[[]]双方括号字符运算 --支持模式匹配
if [[ v$var=ls* ]]

if [ expression ]
then
	{...}
[elif [...]
	...]
else
	{...}
fi
#case
case variable in
pattern1 | pattern2 ) commands1 ;;
pattern3 ) commands2 ;;
*) default commands ;;
esac

#for list值用空格分隔
for var in list
do
commands
done
#c语言方式叠加
for (( a = 1; a < 10; a++ ))
#多个变量
for (( a=1, b=10; a <= 10; a++, b-- ))
do
echo "$a - $b"
done

#while
while test command
do
other commands
done

#until
until test commands
do
	other commands
done

#break 跳出循环层级数
break n
#continue
```
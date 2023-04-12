# sqlplus

## 查看帮助命令
1. 输入command回车就会有帮助命令（只能显示少部分命令，如`desc`，在数据库没打开时依旧生效
2. 显示命令的语法（数据库打开时生效，如`help acc`）

## 环境变量文件

- glogin.sql:全局环境变量，默认已存在，位置$ORACLE_HOME/sqlplus/admin/glogin.sql
- login.sql：用户环境变量，默认不存在，需手动创建，放在home目录下，会覆盖glogin.sql

## sqlplus
```sql
-- help command
-- 查看命令帮助
-- 安装帮助命令
-- @?/sqlplus/admin/help/helpbld.sql ?/sqlplus/admin/help/helpus.sql
help index;

-- show
-- 显示show all命令输出sqlplus中的环境变量
show user;


-- host
-- 执行Linux命令
host vim a.txt 

-- desc
-- 显示表或存储过程等定义信息
desc employees;

-- conn
-- 使用指定的用户名和连接标识符连接到数据库
conn sys/sys@192.168.31.47:1521/orcl as sysdba

-- spool
-- 保存查询结果到文件
spool query_result.txt;
select * from employees where employee_id=105;
spool off;

-- save
-- 把sql脚本保存到文件中
save sql.sql

-- get
-- 把sql脚本读到内存
get sql.sql

-- run | r | / 
-- 运行脚本

-- list | l 
-- 列出内存中的脚本,n：读取指定行
list 2;

-- number
-- 列出指定行

-- delete | del 
-- 删除内存中的脚本，n：删除指定行
del 3;

-- change | c
-- 替换sql脚本的内容，只替换第一次出现的
c/old/new;

-- append | a
-- 在buffer中最后一行的末尾追加字符串
append  test

-- input 
-- 添加指定内容到指定行
1
input ,loc
list


-- col[umn]
-- 重命名列名
col id heading '序列';

-- define var
-- 定义一个临时变量
-- undefine var
-- 取消定义一个临时变量

-- var var
-- 定义一个绑定变量
-- &
-- 定义绑定变量
-- &&
-- 调用定义的变量
select * from employees where employee_id=&id;

```

# show & set
`show`显示环境变量设置
`set var on | off`改变某一变量，只是临时的，要永久生效要修改login.sql或glogin.sql
```
-- show all

-- 标题是否显示
set heading on | off
-- 设置输出结果是否有空行
set newpage on | none
-- 有多少行返回
set feedback on | off


```

# oracle command

tkprof  
plshprof

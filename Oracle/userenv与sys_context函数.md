1.userenv函数   
**作用**:返回有关当前会话的信息
```sql
select userenv('parameter') from dual;
--参数可以是ENTRYID,SESSIONID,TERMINAL,ISDBA,LABLE,LANGUAGE,CLIENT_INFO,LANG
```
2.sys_context函数   
**作用**:SYS_CONTEXT返回parameter与上下文关联的值namespace。可以在SQL和PL / SQL语句中使用此函数。
```sql
select sys_context('namespace','parameter'[,length]) from dual.
--userenv是Oracle提供的默认的命名空间,用于描述当前会话
/*
命名空间userenv预定义参数,
即Oracle上下文参数(上下文context可以理解为环境,背景,当然该环境包括操纵系统环境,Oracle数据库环境),
比如当前系统环境host,Oracle数据库环境,db_name,instance,sessionid,sid,isdba等等.
*/
```
1. 开启 `xp_cmdshell` 功能

```sql
exec sp_configure 'show advanced options',1;
reconfigure
exec sp_configure 'xp_cmdshell',1;
reconfigure
exec sp_configure 'show advanced options',0;
reconfigure
```

2. 授予执行sp的权限

```sql
USE [master]
GO
CREATE USER [cmd] FOR LOGIN [cmd]
GO
USE [master]
GO
ALTER ROLE [db_owner] ADD MEMBER [cmd]
--GRANT EXECUTE ON [sys].[xp_cmdshell] TO [cmd]
GO

```

3. 创建执行cmd的代理账号

```sql
create credential ##xp_cmdshell_proxy_account## with identity = 'hostname\tscdba', secret = 'pwd'
--下面这个语句可能会报错,用上面的比较好
EXEC sp_xp_cmdshell_proxy_account 'hostname\sqlcmd','pwd'
```

不创建报以下错误:

```sql
Msg 15153, Level 16, State 1, Procedure master.dbo.xp_cmdshell, Line 1 [Batch Start Line 9]
The xp_cmdshell proxy account information cannot be retrieved or is invalid. Verify that the '##xp_cmdshell_proxy_account##' credential exists and contains valid information.
```
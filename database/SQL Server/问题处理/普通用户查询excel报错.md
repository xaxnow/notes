Msg 7302, Level 16, State 1, Line 2
Cannot create an instance of OLE DB provider "Microsoft.ACE.OLEDB.12.0" for linked server "(null)".

1. 安装accessDatabaseEngine,要对应操作系统语言 12.0或16.0
2. 开启 `Ad Hoc Distributed Queries` 

即席分布式查询使用 OPENROWSET 和 OPENDATASOURCE 函数连接到使用 OLE DB 的远程数据源。OPENROWSET 和 OPENDATASOURCE 应仅用于引用不经常访问的 OLE DB 数据源。对于将被多次访问的任何数据源，请定义链接服务器

```sql
exec sp_configure 'Ad Hoc Distributed Queries',1
reconfigure
```

3. 修改Linked Servers下Providers中Microsoft.ACE.OLEDB.12.0的属性

- AllowInProcess
SQL Server 允许将访问接口实例化为进程内服务器。 如果未设置此选项，则默认行为是在 SQL Server 进程外实例化访问接口。 在 SQL Server 进程外实例化提供程序可防止 SQL Server 处理程序中的错误。 在 SQL Server 进程外实例化提供程序时，不允许更新或插入引用长列 (文本、 ntext或图像) 。
- DisallowAdHocAccess
SQL Server 不允许通过 OPENROWSET 和 OPENDATASOURCE 函数对 OLE DB 访问接口进行即席访问。 如果未设置此选项，则 SQL Server 也不允许即席访问
- DynamicParameters
表明访问接口允许对参数化查询使用“?”参数标记语法。 仅当该访问接口支持 ICommandWithParameters 接口并支持“?”作为参数标记时，才应设置此选项。 设置此选项后，SQL Server 就可以对提供程序执行参数化查询。 这种对访问接口执行参数化查询的能力会提高某些查询的性能。

```sql
USE [master]
GO
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1
GO
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DisallowAdHocAccess', 1
GO
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1
GO
```

4. 修改完成后修改注册表

```sql
--Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL15.MSSQLSERVER\Providers\Microsoft.ACE.OLEDB.12.0
把DisallowAdHocAccess的值改为0

```

5. 验证

```sql
--Excel文件要和数据库在同一台,且文件不能被其他程序打开
SELECT * 
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
    'Excel 12.0; Database=C:\tools\test.xlsx', 'select * from [sheetName$]');
GO
```
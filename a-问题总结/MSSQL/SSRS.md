### 1. scale-out deployment is not supported in this edition of reporting services

```sql
Use [ReportServer]
Go
Select * from keys;
--From the output of above query note the entries for old server(s) if they were scaled out and delete old server(s) information.
Delete from keys where MachineName ='OLD_Host_Name'
```

### 2. The report server isn’t configured properly. Contact your system administrator to resolve the issue. System administrators: The report server Web Portal URLs and Web Service URLs don’t match. Use Reporting Services Configuration Manager to configure the URLs and ensure they match.

```
确保把防火墙打开
从配置管理器里选择高级把url删除掉重新添加
```

### 3. 发送邮件

```
要授予连接reporting 的账号访问master，msdb的权限。因为要使用一些系统存储过程
```

### 4. 2014 企业版升级到 2017

```
reporting service 的key必须用企业版的，不能升级到标准版。
也可以使用标准版，自己迁移报表。
另外浏览器太旧(比如IE)不能加载新版页面。
```

### 报错记得检查 reporting service 的日志

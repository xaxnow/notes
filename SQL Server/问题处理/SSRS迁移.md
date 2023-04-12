1. scale-out deployment is not supported in this edition of reporting services
```
Use [ReportServer]
Go
Select * from keys;
--From the output of above query note the entries for old server(s) if they were scaled out and delete old server(s) information.
Delete from keys where MachineName ='OLD_Host_Name'
```
2. The report server isn’t configured properly. Contact your system administrator to resolve the issue. System administrators: The report server Web Portal URLs and Web Service URLs don’t match. Use Reporting Services Configuration Manager to configure the URLs and ensure they match.
```
防火墙设置允许SSRS访问的端口
```
3. 服务启动账户

```
最好使用管理员权限账号
```
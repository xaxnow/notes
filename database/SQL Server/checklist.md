# Services configurations

## 杀毒软件排除
### For SQL Server
- SQL Server processes
         %ProgramFiles%\Microsoft SQL Server\<Instance_ID>.<Instance Name>\MSSQL\Binn\SQLServr.exe;
        %ProgramFiles%\Microsoft SQL Server\<Instance_ID>.<Instance Name>\Reporting Services\ReportServer\Bin\ReportingServicesService.exe;
        %ProgramFiles%\Microsoft SQL Server\<Instance_ID>.<Instance Name>\OLAP\Bin\MSMDSrv.exe;
- All SQL Server data files
        These will have extensions of .mdf, .ldf, .ndf, .bak, .trn.
- SQL Server backup files
        These backup files usually have the extensions .bak and .trn.
- Full-Text catalog files
        This is typically the FTData folder in your SQL Server path. Each MSSQLX.X folder, there will be multiple FTData folders that need to be excluded from antivirus scanning.
- Trace files
        These files are created by a user when running a SQL Profiler Trace, usually have the extension .trc.
- Extended Event file targets
        Any Extended Events Trace log files, usually have the extension .xel.
- Third-party SQL backup solution
        If you use a Third-party bkp software like Idera, Red-Gate, LiteSpeed, add those file extensions too.
- Remove filestream containers (if you use them).
- Replication executables and server-side COM objects
- Files in the Replication Snapshot folder
- Schedule scans during the lowest activity hours.

###For Windows Failover Clusters, add these additional Antivirus exclusions (don’t forget this needs to be done on each node):

- The entire quorum/witness disk;
- The \MSDTC directory on disks used by an MSDTC resource;
- The \Cluster subdirectory of the Windows installation;
- All full-text catalog files;
- If you are using Analysis Services, the entire directory on the shared drives containing all Analysis Services data files. If you do not know this location now, remember to set the filter post-installation;
- Antivirus software should be ‘Cluster-Aware’. Check with the Antivirus vendor if it is;

### Here are a few useful links:

- [How to choose antivirus software to run on computers that are running SQL Server](https://support.microsoft.com/en-us/topic/how-to-choose-antivirus-software-to-run-on-computers-that-are-running-sql-server-feda079b-3e24-186b-945a-3051f6f3a95b) ([KB 309422](https://support.microsoft.com/zh-cn/topic/%E5%A6%82%E4%BD%95%E9%80%89%E6%8B%A9%E8%A6%81%E5%9C%A8%E8%BF%90%E8%A1%8C-sql-server-%E7%9A%84%E8%AE%A1%E7%AE%97%E6%9C%BA%E4%B8%8A%E8%BF%90%E8%A1%8C%E7%9A%84%E9%98%B2%E7%97%85%E6%AF%92%E8%BD%AF%E4%BB%B6-feda079b-3e24-186b-945a-3051f6f3a95b));
- [Antivirus software that is not cluster-aware may cause problems with Cluster Services](https://docs.microsoft.com/en-US/troubleshoot/windows-server/high-availability/not-cluster-aware-antivirus-software-cause-issue) ([KB 250355](https://docs.microsoft.com/zh-CN/troubleshoot/windows-server/high-availability/not-cluster-aware-antivirus-software-cause-issue))- article is getting little old, but still has some good info how Antivirus should be chosen;
- [Windows Server Antivirus Exclusions](https://support.microsoft.com/en-us/topic/virus-scanning-recommendations-for-enterprise-computers-that-are-running-windows-or-windows-server-kb822158-c067a732-f24a-9079-d240-3733e39b40bc) ([KB 822158](https://support.microsoft.com/en-us/topic/virus-scanning-recommendations-for-enterprise-computers-that-are-running-windows-or-windows-server-kb822158-c067a732-f24a-9079-d240-3733e39b40bc));
- [More Antivirus exclusions, and not only for MS SQL Servers](https://social.technet.microsoft.com/wiki/contents/articles/953.microsoft-anti-virus-exclusion-list.aspx);


## 获取SQL Server 实例
```sql
EXEC master.sys.xp_regread @rootkey = 'HKEY_LOCAL_MACHINE',
@key = 'SOFTWARE\Microsoft\Microsoft SQL Server',
@value_name = 'InstalledInstances'
```
## SSMS保持最新

## 系统BIOS保持最新
## SQL Services使用非sa账号

确保用户的每个权限都是最小的
```sql
--sysadmin用户
USE master
GO
SELECT DISTINCT p.name AS [loginname] ,
p.type ,
p.type_desc ,
p.is_disabled,
s.sysadmin,
CONVERT(VARCHAR(10),p.create_date ,101) AS [created],
CONVERT(VARCHAR(10),p.modify_date , 101) AS [update]
FROM sys.server_principals p
JOIN sys.syslogins s ON p.sid = s.sid
JOIN sys.server_permissions sp ON p.principal_id = sp.grantee_principal_id
WHERE p.type_desc IN ('SQL_LOGIN', 'WINDOWS_LOGIN', 'WINDOWS_GROUP')
-- Logins that are not process logins
AND p.name NOT LIKE '##%'
AND (s.sysadmin = 1 OR sp.permission_name = 'CONTROL SERVER')
ORDER BY p.name

```

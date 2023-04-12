## 开启clr_enabled 参数
```
sp_configure 'show advanced options', 1
RECONFIGURE
GO

sp_configure 'clr_enabled', 1
RECONFIGURE
GO

sp_configure
GO
```
## 数据库或login需要满足的条件

1. 程序集经过了强名称签名或使用证书进行了 Authenticode 签名。 此强名称 (或证书) 在 内部创建为非对称密钥 (或证书) ，并且具有外部访问程序集的 EXTERNAL ACCESS ASSEMBLY 权限) (或不安全程序集的 UNSAFE ASSEMBLY 权限 () 的相应登录名。
2. 数据库所有者 (DBO) 具有 EXTERNAL **ACCESS** 程序集的 **EXTERNAL** ACCESS ASSEMBLY () 或 **UNSAFE ASSEMBLY** (for **UNSAFE** 程序集) 权限，并且数据库的 [TRUSTWORTHY](https://docs.microsoft.com/zh-cn/sql/relational-databases/security/trustworthy-database-property?view=sql-server-ver15)数据库属性设置为 **ON。**

## 使用sys.sp_add_trusted_assembly添加程序集
```
USE TrustedAsmDB;
GO

CREATE ASSEMBLY Sql2k17TrustedAsm
FROM 'W:\\<path_to_dll>\\Sql2k17TrustedAsm1.dll'
GO
```

创建程序集后导出为脚本,获取到里面的二进制值
```
USE master;
GO
DECLARE @clrName nvarchar(4000) = 'sql2k17trustedasm1, ...'
DECLARE @asmBin varbinary(max) = 0x4D5A90000300000004000000FFFF00...;
DECLARE @hash varbinary(64);

SELECT @hash = HASHBYTES('SHA2_512', @asmBin);

EXEC sys.sp_add_trusted_assembly @hash = @hash,
                                 @description = @clrName;
```
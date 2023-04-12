## 简介
```
ADR 是一个基于文件的资料档案库。用于存放数据库诊断数据（如跟踪、意外事件转储和程序包、预警日志、健康监视报表、核心转储等）。它对存储在不论什么数据库外的多个实例和多种产品使用一个统一的文件夹结构。

因此。在数据库关闭时可用来诊断问题。

从 Oracle Database 11g R1 開始。数据库、自己主动存储管理 (ASM)、集群就绪服务 (CRS) 和其他 Oracle 产品或组件将全部诊断数据都存储在 ADR 中。每种产品的每一个实例都将诊断数据存储在自己的 ADR 主文件夹下。比如，在具有共享存储和 ASM 的 Real Application Clusters 环境中，每一个数据库实例和每一个 ASM 实例在 ADR 中都有一个主文件夹。

利用 ADR 的统一文件夹结构、用于各种产品和实例的统一诊断数据格式以及一组统一的工具。客户和 Oracle 技术支持能够相互关联并分析多个实例的诊断数据。


ADR 根文件夹又称为 ADR 基文件夹。其位置由 DIAGNOSTIC_DEST 初始化參数设置。假设此參数被忽略或留为空值，则数据库在启动时将对 DIAGNOSTIC_DEST 进行例如以下设置：假设设置了环境变量 ORACLE_BASE。则将 DIAGNOSTIC_DEST 设置为 $ORACLE_BASE。假设未环境变量设置 ORACLE_BASE，则将 DIAGNOSTIC_DEST 设置为 $ORACLE_HOME/log

查看各类型诊断文件位置
select * from v$diag_info;
```
## ADR 命令行工具 ADRCI
```

```
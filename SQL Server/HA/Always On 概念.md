# Always On 概念

# Windows Server Failover Clustering

Windows Server 故障转移群集提供了各种基础结构功能来支持所承载的服务器应用程序（如 Microsoft SQL Server 和 Microsoft Exchange）的高可用性和灾难恢复方案。 如果一个群集节点或服务失败，则该节点上承载的服务可在一个称为“故障转移”的过程中自动或手动转移到另一个可用节点。

WSFC节点协同工作，共同提供以下功能：

- **分布式元数据通知** 群集中的每个节点上维护着 WSFC 服务和承载的应用程序元数据。 除了承载的应用程序设置之外，此元数据还包括 WSFC 配置和状态。 对一个节点的元数据或状态进行的更改会自动传播到 WSFC 中的其他节点。
- **资源管理** WSFC 中的各节点可能提供物理资源，如直接连接存储、网络接口和对共享磁盘存储的访问。 承载的应用程序(如SQL Server)将其本身注册为群集资源，并可配置启动和运行状况对于其他资源的依赖关系。
- **运行状况监视** 节点间和主节点运行状况检测是通过结合使用信号样式的网络通信和资源监视来实现的。 WSFC 的总体运行状况是由 WSFC 中节点仲裁的投票决定。
- **故障转移协调** 每个资源都配置为由主节点承载，并且每个资源均可自动或手动转移到一个或多个辅助节点。 基于运行状况的故障转移策略控制节点之间资源所有权的自动转移。 在发生故障转移时通知节点和承载的应用程序，以便其做出适当的响应。

# Always On Availability Groups

数据库级高可用

## 可用性模式

- 异步提交模式

可使性能最大化，但要牺牲高可用性；它仅支持强制 `手动故障转移`（有可能丢失数据），该故障转移一般称为 `强制故障转移`

- 同步提交模式

强调高可用性而不是性能，代价是事务滞后时间增加.并且一旦同步次要副本，即支持手动故障转移（也可以支持自动故障转移）

**注意**

如果某一辅助副本超过了主副本的会话超时期限，则主副本将暂时切换到该辅助副本的异步提交模式。 在该辅助副本重新与主副本连接后，它们将恢复同步提交模式。

## 自动种子设定

初始化次要副本数据库的一种方式。

**要求**：

- 主副本和辅助副本，数据文件和日志文件要一致。
- 对于使用不同平台的，SQL Server 2017起路径可以不一致
- 种子设定通过数据库镜像端点进行通信，需要把镜像终结点端口入站规则打开，即5022端口
- 对于特别大的数据库，可以启用压缩，减小传输成本

## 可用性组侦听器

可用性组侦听器是一个虚拟网络名称 (VNN)，客户端可连接到此名称以访问 Always On 可用性组的主要副本或次要副本中的数据库。 侦听器允许客户端连接到副本，而无需知道 SQL Server 的物理实例名称。 由于侦听器路由流量，因此在发生故障转移后不需要修改客户端连接字符串。

## 分布式事务

在分布式事务中，客户端应用程序和 Microsoft 分布式事务处理协调器（MS DTC 或 DTC）共同配合来确保多个数据源之间的事务一致性。 DTC 是在基于 Windows Server 的受支持操作系统上提供的服务。 DTC 充当分布式事务的“事务处理协调器”。 SQL Server 实例通常充当“资源管理器”。 当数据库位于可用性组中时，每个数据库需为其自身的资源管理器。

## 只读访问副本

添加参数 ApplicationIntent=ReadOnly，并指定Database

[连接到可用性组侦听器 - SQL Server Always On](https://docs.microsoft.com/zh-cn/sql/database-engine/availability-groups/windows/listeners-client-connectivity-application-failover?view=sql-server-ver15)

## 基本可用性组

即标准版支持的功能

## 分布式可用性组

它跨两个单独的可用性组。 加入分布式可用性组的可用性组无需处于同一位置。 它们可以是物理也可以是虚拟的，可以在本地、公有云中或支持可用性组部署的任何位置。 这包括跨域甚至跨平台，例如一个可用性组托管在 Linux，一个托管在 Windows 上。 只要两个可用性组可以进行通信，就可以使用它们配置分布式可用性组。

传统的可用性组在 WSFC 群集中配置资源。 分布式可用性组不会在 WSFC 群集中配置任何内容。 有关它的所有内容都保留在 SQL Server 中。

分布式可用性组要求基础可用性组具有侦听器。 在创建分布式可用性组时，通过 ENDPOINT_URL 参数为其指定已配置的侦听器，而不是像传统可用性组那样，为独立实例提供基础服务器名称（若是 SQL Server 故障转移群集实例 [FCI]，则提供与网络名称资源相关联的值）。 尽管分布式可用性组的每个基础可用性组都具有侦听器，但分布式可用性组不具有侦听器。

## 域独立可用性组

即不需要加入AD域的Windows Server Failover Clustering,但计算机名需要使用相同的 `DNS后缀` 和 `工作组` 。同时要创建证书来确保endpoint的安全性。

[配置域独立工作组可用性组 - SQL Server on Azure VM](https://docs.microsoft.com/zh-cn/azure/azure-sql/virtual-machines/windows/availability-group-clusterless-workgroup-configure)

[创建域独立可用性组 - SQL Server Always On](https://docs.microsoft.com/zh-cn/sql/database-engine/availability-groups/windows/domain-independent-availability-groups?view=sql-server-ver15)

# Always On Failover Clustring Instance

实例级高可用

只有一个节点是活动的
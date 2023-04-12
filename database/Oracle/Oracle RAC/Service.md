#### Service由来
```
根据不同的数据库类别划分不同的等级(看人下菜,区别对待).由部署模式(主备型,对称型,非对称型)
```
#### 区别对待实现方法(部署模式与resource manager共同实现)
+ 主备:一个节点有问题,切到另一节点
+ 对称:服务在所有节点运行
+ 非对称:部分节点运行,其他节点作为后备
#### 可用实例和非可用实例
```
因为部署的差异,service活动范围受限(只能在其可用实例运行),所以又对实例进行首选实例和可用实例划分(优先首选,备用可用),要把service从可用实例恢复到首选需dba干预
```
**区别对待实现**
1.创建Service并指定消费组映射
2.消费组定义优先级,资源许可,Service继承优先级,资源许可
3.用户通过Service连接到实例,会话会在建立连接时自动分配到这个消费组从而得到资源
4.资源管理器完成服务管理
#### Service实战
`EM和srvctl`
```
oracle用户:srvctl add service -d racdb -s testdb -i racdb1,racdb2
srvctl start service -d racdb -s testdb
#通过查看scan监听器查看Service状态
grid用户:lsnrctl status listener_scan1
```
#### service连接目标及服务品质
```
长连接:根据实例数量平衡连接,会话数量
短连接:根据LB建议细分3类
a:不启用LBA,根据cpu利用程度做分配参考.
b,c:启用LBA,根据响应时间和吞吐量参考.
```
#### TAF(透明应用程序故障转移)
```
客户端到数据库的连接断掉后能重新连接到其他节点.新连接叫备用或Failover连接
两种模式(区别:是否支持断点续传):
1.SESSION:之前的SQL不会继续执行
2.SELECT:中断的是select语句继续执行,继续提交剩余数据,已提交的记录不会重复
Failover连接建立时机:
1.BASIC:当连接断了之后建立新连接(响应式连接)
2.PRECONNECT:提前建好备用连接,连接断了立马切过来(预防式连接)
创建:
1.Admin管理:支持basic和preconnect
2.Policy管理:支持basic
srvctl add service -h
```
#### 数据库资源管理器(DRM需激活)
```
与Service孟不离焦,焦不离孟
Service负责逻辑层面的工作负载划分,DRM基于Service做资源分配
1.消费者组:代表一组相似需求的用户,RM根据用户组分配资源.用户和消费组可以通过用户名,模块名service名完成映射
2.资源计划指令(RP Directive):定义资源如何在用户组间分配(如CPU)
３.资源计划：资源管理顶端，把用户组和资源指导计划绑定,同时又可以和调度窗口结合(不同时间不同计划)

实操:(EM或存储过程)
1.创建工作区
dbms_resource_manager.create_pending_area();
2.创建使用者组
dbms_resource_manager.create_consumer_group(consumer => 'boss_grp',comment => '老板团');
3.创建消费计划:
dbms_resource_manager.create_plan(plan => 'test plan',comment =>'rac' samplan);
4.创建计划指令
dbms_resource_manager.create_plan_directive('test plan',group_or_sub_plan =>'boss_grp',mgmt_p1 =>80,comment =>'特级服务');
5.创建服务和使用者组服务关系
dbms_resource_manager.set_consumer_group_mapping(
  attribute => dbms_resource_manager.service_name.
  value =>'bosssrv'
  consumer_group => 'boss_grp'
);
6.检验工作区,没问题就提交
dbms_resource_manager.validate_pending_area();
dbms_resource_manager.submit_pending_area();
7.给某个用户切换赋予切换消费组权力(所有用户public))
dbms_resource_manager_privs.grant_switch_consumer_group('ls','boss_grp','false');
8.启用消费计划
alter system set resource_manager_plan ='boss_pan' scope=both sid='*';
9.启用资源限制
alter system set resource_limit=true scope=both sid='*';
```
#### 增强DRM-Instance Caging
`实现不同实例间的资源分配`
#### IO校准(IO Calibrate)
`测量数据库IO能力(IOPS和Mb(基于dbms_resource_manager.calibrate_io())`
####  3个service名字
+ db_unique_name+db_domain:
+ SYS$BACKUPGROUD:数据库后台进程使用
+ SYS$USERS:用于使用sid连接的老顽固
#### tnsnames.ora
```sql
#service方式
RACDB =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = scan)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = racdb)
    )
  )
#sid方式
orcl =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = orcl)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (sid = orcl)
    )
  )


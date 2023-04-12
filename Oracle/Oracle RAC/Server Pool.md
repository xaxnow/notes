#### Server Pool
```
Service划分了业务势力范围(首选和可用实例),DM进一步限制Service活动半径.然而我们并不想关心业务使用哪台机器,只要为业务提供足够多的机器,完全不用在意使用哪几台机器.显然靠service和DM是不够的.
同时为了满足分配时考虑业务的重要性,实现动态调整,从而引入Server Pool.
这里同时又提出了一种基于策略管理的概念(Policy-Based Management),即依靠机器,算法,自动化而不是靠人(dba,基于管理员管理(Administrator-Based Management))
Server Pool就是基于策略管理的产物,它它通过定义若干个Server Pool,对每个Pool做出3个约定:服务器数量的下限,服务器数量的上限,重要程度.
数据库通过Service和Server Pool打通,一个Service只属于一个Pool,但一个数据库的不同Service可以分属于不同的Server Pool.从而实现业务和资源的解耦.
```
#### Pool分类
+ Genneric Pool(基于管理员管理使用)
```
这个Pool既是类别也是个具体的Pool,它可以有很多child pool.admin管理的并不直接使用它而是创建一个ora.dbname的Pool作为其child pool存在.
产生的方式有两种:dba创建,旧版本升级
以srvctl创建的池叫数据库池,名字前自动加上ora.前缀(dbca使用的就是srvctl),是Oracle资源的容器.而crsctl创建的是非数据库池,作用相反
```
+ Free Pool:后备军
+ Database Pool:定向的由DBA手工创建,否则不会产生

#### TAF
```


```


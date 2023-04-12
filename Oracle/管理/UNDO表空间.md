##### 1.作用及原理

##### 2.创建还原表空间

```
create undo tablespace ls_undo datafile
'D:\APP\LS\ORADATA\ORCL\UNDOTBS02.DBF' size 10m autoextend on;
```



##### 3.维护还原表空间

```
3.1 重命名还原表空间
	alter tablespace ls_undo rename to ls_undo01;
3.2 增加数据文件
	alter tablespace ls_undo add datafile 'D:\APP\LS\ORADATA\ORCL\UNDOTBS03.DBF' size 10m;
3.3 设置数据文件自动扩展
	alter database datafile 'D:\APP\LS\ORADATA\ORCL\UNDOTBS03.DBF'
	autoextend on;
```



##### 4.切换还原表空间

```
alter system set undo_tablespace = ls_undo;
切换涉及状态
（1）旧的表空间上有事务正在执行，则该旧的表空间变成pending ofline。
（2）用户事务正常运行，切换操作结束，不会等待旧的undo表空间的事务结束。
（3）切换以后，所有新的事务所生成的undo数据不会存放在旧的undo表空间，而是会使用新的undo表空间。
（4）Pending offline状态的undo 表空间不能被删除。
（5）旧的undo表空间上的所有的事务都提交以后，旧的undo表空间从pending ofline状态变成offline状态，表空间可以删除。
（6）Drop tablespace undotbs1相当于drop tablespace undotbsl including contents。
（7）如果undo表空间包含inactive状态的undo数据块，不影响被删除，但是可能产生ORA-1555错误，因此最好等待超过undo retention以后，再删除表空间。
```

##### 5.删除还原表空间

```
drop tablespace ls_undo;
```


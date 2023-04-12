### ASM架构
### ASM管理
```sql
--创建磁盘组[attribute可以通过v$asm_attribute查看]
create diskgroup dgtest external|normal|high|flex|extend redundancy disk '/dev/oracleasm/disks/TEST01' [attribute 'compatible.rdbms'='11.2.0.0.0'];
--改变磁盘组属性(兼容性设置属性compatible.asm和compatible.rdbms及compatible.advm会影响其他属性设置)
alter diskgroup dgtest set attribute 'disk_repair_time'='3.6h';
--为磁盘组添加成员
alter diskgroup dgtest add disk '/dev/oracleasm/disks/TEST02';
--offline磁盘组
alter diskgroup dgtest offline disks in failgroup fg1 drop after 5h;
--删除磁盘组
drop diskgroup dgtest;
--挂载/卸载磁盘组
alter diskgroup dgtest mount/dismount;
```

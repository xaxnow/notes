# Snapshot
```
copy-on-write
sparse file
```
某个时点的某个数据库的快照，生成之后就不会有任何改变。
它使用copy-on-write(写时复制)技术，即有任何数据页在源数据库中改变，就会把原来版本的数据拷贝到一个NTFS稀疏文件中,这个稀疏文件就会被snapshot使用。稀疏文件是一个一开始为空，没有分配大小的，后面随着源数据库数据页被修改原来的页被拷贝进稀疏文件的文件。

## 优劣
**优势**：
- 用来做报表，减少数据库锁争用
- 当用户数据出错时，可以恢复数据

**劣势**：
- 数据过时，需要定时刷新snapshot
- 增加I/O，内存使用

## 创建
```sql
create database snapshot_of_adventure
on primary(
    --这里的name是adventure数据文件的逻辑名
    name=N'',filename=N'ff.ss'
)
as snapshot of adventure;
```
## 从snapshot恢复
```sql
restore database adventure from database_snapshot='snapshot_name'
```
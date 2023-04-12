## 步骤
```
伸:
rac one node 转换(convert)成 rac
添加实例
启动实例
缩:
dbca 删除实例(检查v$log查看日志线程)
rac 转换成 rac one node
```
## instance caging
`控制每个实例资源利用`
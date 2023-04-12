### 可能引起CPU问题的

+ missing indexes
+ SARGable stand for search arguments
```
避免使用函数导致谓词不能使用索引(隐式转换),即应该直接使用列与值进行比较
```
+ 隐式转换
```
即在比较时数据类型不匹配而导致SQL转换的,如varchar和NVARCHAR的值比较时，可以通过CAST/CONVERT解决

```

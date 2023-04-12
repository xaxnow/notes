# keep函数介绍
```sql
-- keep是Oracle下的另一个分析函数，他的用法不同于通过over关键字指定的分析函数，可以用于这样一种场合下：
-- 取同一个分组下以某个字段排序后，对指定字段取最小或最大的那个值。
-- 从这个前提出发，我们可以看到其实这个目标通过一般的row_number分析函数也可以实现，即指定rn=1。但是，
-- 该函数无法实现同时获取最大和最小值。或者说用first_value和last_value，结合row_number实现，
-- 但是该种方式需要多次使用分析函数，而且还需要套一层SQL。于是出现了keep。

-- 语法：
-- min | max(column1) keep (dense_rank first | last order by column2) over (partion by column3);

-- 最前是聚合函数，可以是min、max、avg、sum。。。
-- column1为要计算的列；
-- dense_rank first，dense_rank last为keep 函数的保留属性，表示分组、排序结果集中第一个、最后一个；
-- 解释：返回按照column3分组后，按照column2排序的结果集中第一个或最后一个最小值或最大值column1。

select deptno,
       max(sal) keep(dense_rank first order by sal) first_max,
       max(sal) keep(dense_rank last order by sal) last_max
  from emp
 group by deptno;
```
# 一、分析函数
```sql
-- Oracle从8.1.6开始提供分析函数，专门用于解决复杂报表统计需求的功能强大的函数，
-- 它可以在数据中进行分组然后计算基于组的某种统计值，并且每一组的每一行都可以返回一个统计值。分析函数用于计算基于组的某种聚合值。

-- 它和聚合函数的不同之处是：对于每个组返回多行，而聚合函数对于每个组只返回一行。普通的聚合函数用group by分组，
-- 每个分组返回一个统计值；而分析函数采用partition by分组，并且每组每行都可以返回一个统计值。

-- 1、分析函数的形式：
-- 分析函数带有一个开窗函数over()，在窗口函数中包含三个分析子句:分组(partition by), 排序(order by), 窗口(rows) ，
-- 他们的使用形式如下：over(partition by xxx order by yyy rows between zzz)。
-- 注：窗口子句在这里我只说rows方式的窗口,range方式和滑动窗口也不提。

-- 例如：统计函数+over()、排序函数+over()、数据分布函数+over()、统计分析函数+over()。

-- 2、开窗函数：
开窗函数指定了分析函数工作的数据窗口大小，这个数据窗口大小可能/*会随着行的变化而变化*/。例如over函数
```
# 二、窗口函数
```sql
-- 窗口函数中常用的子句有：分区（partition by）、排序（order by）、范围（rows between或range between），
-- 以及她们的混合方式。形式如下：over(partition by xxx order by yyy rows between zzz)
```
# 三、常见分析函数
```sql
-- row_number() over(partition by … order by …)
-- rank() over(partition by … order by …)
-- dense_rank() over(partition by … order by …)
select deptno,sal,row_number() over(partition by deptno order by sal) num
,rank() over(partition by deptno order by sal) rank
,dense_rank() over(partition by deptno order by sal) dens from emp;

-- count() over(partition by … order by …)
-- max() over(partition by … order by …)
-- min() over(partition by … order by …)
-- sum() over(partition by … order by …)
-- avg() over(partition by … order by …)
select deptno,
       sal,
       count(sal) over(partition by deptno order by sal) cn,
       max(sal) over(partition by deptno order by sal) mx,
       min(sal) over(partition by deptno order by sal) mn,
       avg(sal) over(partition by deptno order by sal) ag,
       sum(sal) over(partition by deptno order by sal) sm
  from emp;

-- first_value() over(partition by … order by …)
-- last_value() over(partition by … order by …)
select deptno,sal,first_value(sal) over(partition by deptno order by sal) first
,last_value(sal) over(partition by deptno order by sal) last from emp;

-- lag() over(partition by … order by …)
-- lead() over(partition by … order by …)
-- Lag和Lead函数可以在一次查询中取出同一字段的前N行的数据和后N行的值。语法：lag(exp_str,offset,defval) over()
-- exp_str 是要做对比的字段；
-- offset 是exp_str字段的偏移量 比如说 offset 为2 则 拿exp_str的第一行和第三行对比，第二行和第四行，依次类推，offset的默认值为1！
-- defval是当该函数无值可用的情况下返回的值。Lead函数的用法类似。
select deptno,
       sal,
       job,
       lag(job,2,1) over(partition by deptno order by sal) lg
  from emp;
```
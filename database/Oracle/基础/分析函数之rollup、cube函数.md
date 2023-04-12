# rollup()函数、cube()函数
```sql
--通常与group by 子句一起使用，根据维度在分组后进行聚合操作
--应用场景：为每个分组返回一个小计，同时为所有分组返回总计
SELECT ENAME,DEPTNO,SUM(SAL) FROM EMP GROUP BY ROLLUP(DEPTNO,ENAME);
--ROLLUP和CUBE独立考虑每一列再决定其必须计算小计，对rollup()而言，通过列表来确定分组，
--而cube函数则对每种可能的列组合分组
/*
rollup(a,b,c,d...)等价于grouping sets(
	(a,b,c,d...)
	...
	(a,b,c)
	(a,b)
	(a)
	())
*/
rollup()辅助函数:往往是为了过滤掉一部分统计数据，而达到美化统计结果的作用。

--grouping():必须接受一列且只能接受一列做为其参数。参数列值为空返回1，参数列值非空返回0。（即如果参数的列的值在rollup中，则返回1；否则返回0）
SELECT ENAME,DEPTNO,SUM(SAL),grouping(ename),grouping(deptno) FROM EMP GROUP BY ROLLUP(DEPTNO,ENAME);

--grouping_id():必须接受一列或多列做为其参数。返回值为按参数排列顺序，依次对各个参数使用grouping()函数，
--并将结果值依次串成一串二进制数然后再转化为十进制所得到的值
SELECT ENAME,DEPTNO,SUM(SAL),grouping_id(deptno,ename) FROM EMP GROUP BY ROLLUP(DEPTNO,ENAME);
例如：grouping(A) = 0 ; grouping(B) = 1;
则：grouping_id(A,B) = (01)2 =0*2^1+1*2^0= 1;
	grouping_id(B,A) = (10)2 =1*2^1+0*2^0=2;

--group_id()函数：调用时不需要且不能传入任何参数。返回值为某个特定的分组出现的重复次数(第一大点中的第3种情况中往往会产生重复的分组)。
--重复次数从0开始，例如某个分组第一次出现则返回值为0，第二次出现时返回值为1，……，第n次出现返回值为n-1。可用来去重

grouping sets()函数：指定感兴趣的分组,减少计算整个维度的消耗
SELECT DEPTNO,ENAME,SUM(SAL)FROM EMP GROUP BY grouping sets (DEPTNO,ENAME);
```

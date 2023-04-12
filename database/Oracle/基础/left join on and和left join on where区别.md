```sql
SELECT E.ENAME,E.JOB,D.DNAME,D.DEPTNO FROM EMP E LEFT JOIN DEPT D ON E.DEPTNO=D.DEPTNO WHERE E.JOB='CLERK';
--LEFT JOIN ON WHERE含义：关联出左表与右表记录后，过滤出只符合WHERE后面左表条件的记录，此时已经没有使用LEFT JOIN的含义了。
SELECT E.ENAME,E.JOB,D.DNAME,D.DEPTNO FROM EMP E LEFT JOIN DEPT D ON E.DEPTNO=D.DEPTNO AND E.JOB='CLERK';
--LEFT JOIN ON AND含义：返回左表所有记录和右表与条件匹配的记录，即不管ON后面的判断是否为真,左表都会返回所有记录。

--总结，当需求是需要过滤记录时使用带WHERE的，而当需求是保留左表与复合条件的右表记录时使用AND.

--那么问题来了，我们知道左右连接中ON后面跟的条件是两个表的关系列，那么如果没有使用关系列连接是怎样的情况呢？
SELECT E.ENAME,E.JOB,D.DNAME,D.DEPTNO FROM EMP E LEFT JOIN DEPT D ON E.JOB='CLERK';
--似乎不好理解那么再做另一个查询
SELECT E.ENAME,E.JOB,D.DNAME,D.DEPTNO FROM EMP E RIGHT JOIN DEPT D ON E.JOB='CLERK';
--由上面两个结果集可以看出，左右连接返回的是符合条件的笛卡儿积记录和主表中还未在笛卡儿积中出现的主表记录。
```
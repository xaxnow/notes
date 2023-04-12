1.创建计划，使JOBNO和存储过程关联
```sql
DECLARE 
    JOBNO INTEGER;
BEGIN
    DBMS_JOBS.SUBMIT ( JOBNO, 'PRO_NAME;', SYSDATE, 'SYSDATE+1/24' );
END;

--DBMS_JOB.SUBMIT参数说明
DBMS_JOB.SUBMIT (
JOBNO => JOBID,        --对应的唯一 ID （ JOBID <-> JOBNAME）唯一映射 
PROCEDURENAME => 'YOUR_PROCEDURE;',        --调用的存储过程名称 
NEXT_DATE => SYSDATE,       --下次执行的时间 (第一次执行的时间） 
INTERVAL => 'SYSDATE+1/(24*60)' );      --每次执行间隔的时间
```
2.执行、停止、删除计划
```sql
--方式一、查询出JOBNO,到cmd执行
SELECT * FROM USER_JOBS;
EXEC DBMS_JOB.RUN(JOBNO);

--方式二、直接SQL执行   
DECLARE 
  JOBNO INTEGER; 
BEGIN 
  -- 查找计划号 
  SELECT JOB INTO JOBNO FROM USER_JOBS;
  --执行计划
  DBMS_JOB.RUN(JOBNO); 
  -- 停止计划，不再继续执行 
  DBMS_JOB.BROKEN(JOBNO,TRUE); 
  -- 停止计划，并在两分钟后继续执行 
  DBMS_JOB.BROKEN(JOBNO,TRUE,SYSDATE+(2/24/60)); 
  --删除计划
  DBMS_JOB.REMOVE(JOBNO)
END;
```
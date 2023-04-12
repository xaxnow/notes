## 正在运行的SQL和未提交的事务
```sql
select * from
sys.dm_exec_connections ec
inner join (select * from sys.dm_exec_sessions where session_id>50 
and status='running'
or open_transaction_count>0) es
on ec.session_id=es.session_id
CROSS APPLY sys.dm_exec_sql_text(ec.most_recent_sql_handle) sql

--未提交的事务
select * from sys.dm_tran_session_transactions where open_transaction_count>0
```
## 2
```sql
select   db_name(r.database_id) as db_name
        ,s.group_id
        ,r.session_id
        ,r.blocking_session_id as blocking
        ,s.login_name
        ,r.wait_type as current_wait_type
        ,r.wait_resource
        ,r.last_wait_type
        ,r.wait_time/1000 as wait_s
        ,r.status as request_status
        ,r.command
        ,r.cpu_time
        ,r.reads
        ,r.writes
        ,r.logical_reads
        ,r.total_elapsed_time
        ,r.start_time
        ,s.status as session_status
        ,substring( st.text, 
                    r.statement_start_offset/2+1,
                    ( case when r.statement_end_offset = -1 
                                then len(convert(nvarchar(max), st.text))
                           else (r.statement_end_offset - r.statement_start_offset)/2
                      end 
                    )
                ) as individual_query
from sys.dm_exec_requests r
inner join sys.dm_exec_sessions s 
    on r.session_id=s.session_id
outer APPLY sys.dm_exec_sql_text(r.sql_handle) as st
where ((r.wait_type<>'MISCELLANEOUS' and r.wait_type <> 'DISPATCHER_QUEUE_SEMAPHORE' ) or r.wait_type is null)
    and r.session_id>50
    and r.session_id<>@@spid
order by r.session_id asc
```
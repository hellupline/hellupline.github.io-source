---
title: 'mysql'

---


## inspect bad queries

```sql
SELECT
    CONCAT("CALL mysql.rds_kill_query('" , ID, "');") AS "run_to_kill",
    @@hostname AS "hostname",
    pl.ID AS "id",
    pl.USER AS "user",
    pl.DB AS "database",
    pl.COMMAND AS "command",
    pl.STATE AS "state",
    trx.trx_operation_state AS "operation_state",
    trx.trx_isolation_level AS "isolation_level",
    pl.TIME / 60 AS "time_minute",
    pl.INFO AS "text"
FROM information_schema.PROCESSLIST AS pl
LEFT OUTER JOIN information_schema.INNODB_TRX AS trx ON pl.ID = trx.trx_mysql_thread_id
WHERE pl.COMMAND NOT IN ('Sleep', 'Connect', 'Binlog Dump')
ORDER BY pl.TIME DESC;
```

```sql
SELECT 
    a.trx_id, 
    a.trx_state, 
    a.trx_started, 
    TIMESTAMPDIFF(SECOND,a.trx_started, now()) as "Seconds Transaction Has Been Open", 
    a.trx_rows_modified, 
    b.USER, 
    b.host, 
    b.db, 
    b.command, 
    b.time, 
    b.state 
FROM
    information_schema.innodb_trx a, 
    information_schema.processlist b 
WHERE 
    a.trx_mysql_thread_id=b.id
    AND TIMESTAMPDIFF(SECOND,a.trx_started, now()) > 10 
ORDER BY
    trx_started
```


## allow kill process on rds

```sql
GRANT EXECUTE ON PROCEDURE `mysql`.`rds_kill_query` TO `operator`@`%`;
GRANT EXECUTE ON PROCEDURE `mysql`.`rds_kill` TO `operator`@`%`;
GRANT SELECT ON TABLE `information_schema`.`PROCESSLIST` TO `operator`@`%`;
```


## kill query in rds

```sql
SHOW FULL PROCESSLIST; -- or the bad queries above
EXPLAIN FOR CONNECTION PID;
KILL PID if vanilla mysql;  -- if vanilla mysql
CALL mysql.rds_kill_query(PID);
```


## list users

```sql
SELECT user FROM mysql.user;
```


## create user

```sql
CREATE USER 'user'@'%' IDENTIFIED BY 'PASSWORD';
GRANT SELECT on DATABASE.* TO 'user'@'%';
```


## inspect user permissions

```sql
SHOW GRANTS FOR 'user'@'%';
```

```sql
SELECT *
FROM information_schema.user_privileges
WHERE
	PRIVILEGE_TYPE NOT IN ( 'USAGE', 'SELECT')
    AND GRANTEE NOT IN ( "'rdsadmin'@'localhost'", "'rdsrepladmin'@'%'")
```


## inspect table size

```sql
SELECT
    TABLE_SCHEMA AS "schema_name",
    "ALL TABLES" AS "table_name",
    ROUND(SUM(DATA_LENGTH + INDEX_LENGTH), 2) AS "schema_size"
FROM information_schema.TABLES
WHERE TABLE_SCHEMA NOT IN ('information_schema', 'performance_schema', 'mysql', 'sys', 'tmp')
GROUP BY TABLE_SCHEMA
HAVING ROUND((SUM(DATA_LENGTH + INDEX_LENGTH) / @UNIT_SIZE), 2) > 1000
UNION ALL
SELECT
    TABLE_SCHEMA AS "schema_name",
    TABLE_NAME AS "table_name",
    ROUND((DATA_LENGTH + INDEX_LENGTH), 2) AS "schema_size"
FROM information_schema.TABLES
WHERE TABLE_SCHEMA NOT IN ('information_schema', 'performance_schema', 'mysql', 'sys', 'tmp')
ORDER BY "schema_name", "schema_size" DESC;
```


## inspect replication status

```sql
SHOW SLAVE STATUS;
SHOW SLAVE HOSTS;
```

### inspect replication status as query

```sql
SELECT
	smi.master_log_name AS Master_Log_File,
	smi.master_log_pos AS Read_Master_Log_Pos,
	ssi.master_log_pos AS Exec_Master_Log_Pos,
	rcs.service_state AS Slave_IO_Running,
	rss.service_state AS Slave_SQL_Running,
	t.processlist_time AS Seconds_Behind_Master,
	rcs.last_error_number AS Last_IO_Errno,
	rcs.last_error_message AS Last_IO_Error,
	rss.last_error_number AS Last_SQL_Errno,
	rss.last_error_message AS Last_SQL_Error,
	tc.processlist_state AS Slave_IO_State,
	t.processlist_state AS Slave_SQL_Running_State 
FROM
	mysql.slave_master_info smi
	JOIN mysql.slave_relay_log_info ssi USING ( channel_name )
	JOIN PERFORMANCE_SCHEMA.replication_connection_status rcs USING ( channel_name )
	LEFT JOIN PERFORMANCE_SCHEMA.replication_applier_status_by_worker rss USING ( channel_name )
	LEFT JOIN PERFORMANCE_SCHEMA.threads t ON ( rss.thread_id = t.thread_id )
	LEFT JOIN PERFORMANCE_SCHEMA.threads tc ON ( rcs.thread_id = tc.thread_id )
```


## inspect innodb buffer pool pages
```sql
WITH
    "total" AS (
        SELECT VARIABLE_VALUE AS value
        FROM information_schema.GLOBAL_STATUS
        WHERE VARIABLE_NAME = 'Innodb_buffer_pool_pages_total'
    ),
    "dirty" AS (
        SELECT VARIABLE_VALUE AS value
        FROM information_schema.GLOBAL_STATUS
        WHERE VARIABLE_NAME = 'Innodb_buffer_pool_pages_dirty'
    )
SELECT
    total.value AS 'total_pages',
    dirty.value AS 'dirt_pages',
    ROUND((dirty.value / total.value) * 100, 2) AS 'dirt_percentage'
FROM total
INNER JOIN dirt;
```


## inspect alter tables
```sql
SELECT
  EVENT_NAME,
	WORK_COMPLETED,
  WORK_ESTIMATED,
  ROUND(100 * WORK_COMPLETED / WORK_ESTIMATED, 2) AS pct_complete,
  ROUND(TIMER_WAIT / 1e12 / 60, 2) AS duration_minutes
FROM performance_schema.events_stages_current;
```

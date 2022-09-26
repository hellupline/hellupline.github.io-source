---
title: mysql
weight: 140
type: docs
bookCollapseSection: false
bookFlatSection: false
bookToc: true
---

## inspect bad queries

```sql
SELECT
    CONCAT("CALL mysql.rds_kill_query('" , ID, "');") AS "run_to_kill",
    pl.ID AS "id",
    pl.USER AS "user",
    pl.DB AS "database",
    pl.COMMAND AS "command",
    pl.STATE AS "state",
    trx.trx_operation_state AS "operation_state",
    trx.trx_isolation_level AS "isolation_level",
    pl.TIME / 60 AS "time_minute",
    pl.INFO AS "text",
		trx.*
FROM
    information_schema.PROCESSLIST AS pl
RIGHT OUTER JOIN
    information_schema.INNODB_TRX AS trx ON pl.ID = trx.trx_mysql_thread_id
WHERE
    pl.COMMAND NOT IN ('Sleep', 'Connect', 'Binlog Dump')
ORDER BY
    pl.TIME DESC```

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
SELECT
	* 
FROM
	information_schema.user_privileges 
WHERE
	PRIVILEGE_TYPE NOT IN (
        'USAGE',
        'SELECT'
    ) 
	AND GRANTEE NOT IN (
        "'rdsadmin'@'localhost'",
        "'rdsrepladmin'@'%'"
    )
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

CALL mysql.rds_kill_query(PID);
```


## inspect replication status

```sql
SHOW SLAVE STATUS;

SHOW SLAVE HOSTS;
```

```sql
SELECT 
    dirty.Value AS 'Dirty Pages',
    total.Value AS 'Total Pages',
    ROUND(100*dirty.Value/total.Value, 2) AS 'Dirty Pct'
FROM 
    (
        SELECT 
            VARIABLE_VALUE AS Value 
        FROM 
            information_schema.GLOBAL_STATUS 
        WHERE   
            VARIABLE_NAME = 'Innodb_buffer_pool_pages_total'
    ) AS total
INNER JOIN 
    (
        SELECT 
            VARIABLE_VALUE AS Value 
        FROM 
            information_schema.GLOBAL_STATUS 
        WHERE 
            VARIABLE_NAME = 'Innodb_buffer_pool_pages_dirty'
    ) AS dirty;
```

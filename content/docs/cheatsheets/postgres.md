---
title: 'postgres'

---


## Check long running transactions

```sql
SELECT
	FORMAT('SELECTR pg_terminate_backend(%s)', pid) AS "run to kill",
	pid AS "process ID",
	usename AS "username",
	client_addr AS "source ip",
	EXTRACT(EPOCH FROM (DATE_TRUNC('second', now() - pg_stat_activity.query_start))) AS "duration",
	state as "state",
	TRIM(LEADING E'\n' FROM query) AS "query"  -- Adjusts query visualization in some softwares
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY duration DESC;
```


## show where a user has permissions

```sql
WITH
    tables AS (
        SELECT
            catalog_name AS "catalog_name",
            schema_name AS "schema_name",
            tablename AS "table_name"
        FROM information_schema.schemata
        JOIN pg_tables ON schemata.schema_name = pg_tables.schemaname
    ),
    roles AS (
        SELECT 'role' AS kind, rolname AS name FROM  pg_roles
        UNION
        SELECT 'user' AS kind, usename AS name FROM pg_user
    ),
    permissions AS (
        SELECT
            tables.catalog_name AS "catalog_name",
            tables.schema_name AS "schema_name",
            tables.table_name AS "table_name",
            roles.kind AS "role_kind",
            roles.name AS "role_name",
            HAS_TABLE_PRIVILEGE(roles.name, tables.schema_name || '.' || tables.table_name, 'select') AS "has_select",
            HAS_TABLE_PRIVILEGE(roles.name, tables.schema_name || '.' || tables.table_name, 'insert') AS "has_insert",
            HAS_TABLE_PRIVILEGE(roles.name, tables.schema_name || '.' || tables.table_name, 'update') AS "has_update",
            HAS_TABLE_PRIVILEGE(roles.name, tables.schema_name || '.' || tables.table_name, 'delete') AS "has_delete",
            HAS_TABLE_PRIVILEGE(roles.name, tables.schema_name || '.' || tables.table_name, 'references') AS "has_references"
        FROM tables, roles
        ORDER BY tables.schema_name ASC, tables.table_name ASC, roles.kind ASC, roles.name ASC
    )
SELECT *
FROM permissions
WHERE
    catalog_name IN ('my_app') AND
    schema_name NOT IN ('pg_catalog') AND
    table_name IN ('my_table', 'my_other_table') AND
    role_name in ('app_reader') AND
    has_select = false
```


## show objects ownership

```sql
SELECT
	pg_namespace.nspname AS "object_schema",
	pg_class.relname AS "object_name",
	pg_roles.rolname AS "owner",
	case pg_class.relkind
		when 'r' then 'TABLE'
		when 'm' then 'MATERIALIZED_VIEW'
		when 'i' then 'INDEX'
		when 'S' then 'SEQUENCE'
		when 'v' then 'VIEW'
		when 'c' then 'TYPE'
		else pg_class.relkind::text
	end AS "object_type"
FROM pg_class
JOIN pg_roles ON pg_roles.oid = pg_class.relowner
JOIN pg_namespace ON pg_namespace.oid = pg_class.relnamespace
WHERE
	pg_namespace.nspname NOT IN ('information_schema', 'pg_catalog')
	AND pg_namespace.nspname NOT IN ('pg_toast')
	AND pg_roles.rolname = current_user -- remove this if you want to see all objects
ORDER BY pg_namespace.nspname, pg_class.relname;
```


## show table sizes

```sql
SELECT
	pg_namespace.nspname AS "object_schema",
	pg_class.relname AS "object_name",
	CASE 
		WHEN pg_class.relkind = 'r' THEN 'ordinary table'
		WHEN pg_class.relkind = 'i' THEN 'index'
		WHEN pg_class.relkind = 'S' THEN 'sequence'
		WHEN pg_class.relkind = 't' THEN 'TOAST table'
		WHEN pg_class.relkind = 'v' THEN 'view'
		WHEN pg_class.relkind = 'm' THEN 'materialized view'
		WHEN pg_class.relkind = 'c' THEN 'composite type'
		WHEN pg_class.relkind = 'f' THEN 'foreign table'
		WHEN pg_class.relkind = 'p' THEN 'partitioned table'
		WHEN pg_class.relkind = 'I' THEN 'partitioned index'
	END AS "ojbect_kind",
	pg_size_pretty(pg_total_relation_size(pg_class.oid)) AS "total_size"
FROM
	pg_class
LEFT JOIN
	pg_namespace ON (pg_namespace.oid = pg_class.relnamespace)
WHERE
	pg_namespace.nspname NOT IN ('pg_catalog', 'information_schema')
ORDER BY
	pg_total_relation_size(pg_class.oid) DESC;
```

```
WITH 
	table_sizes AS (
		SELECT
			pg_namespace.nspname AS "object_schema",
			pg_class.relname AS "object_name",
			CASE 
				WHEN pg_class.relkind = 'r' THEN 'ordinary table'
				WHEN pg_class.relkind = 'i' THEN 'index'
				WHEN pg_class.relkind = 'S' THEN 'sequence'
				WHEN pg_class.relkind = 't' THEN 'TOAST table'
				WHEN pg_class.relkind = 'v' THEN 'view'
				WHEN pg_class.relkind = 'm' THEN 'materialized view'
				WHEN pg_class.relkind = 'c' THEN 'composite type'
				WHEN pg_class.relkind = 'f' THEN 'foreign table'
				WHEN pg_class.relkind = 'p' THEN 'partitioned table'
				WHEN pg_class.relkind = 'I' THEN 'partitioned index'
			END AS "object_kind",
			pg_size_pretty(pg_total_relation_size(pg_class.oid)) AS "total_size"
		FROM
			pg_class
		LEFT JOIN
			pg_namespace ON (pg_namespace.oid = pg_class.relnamespace)
		WHERE
			pg_namespace.nspname NOT IN ('pg_catalog', 'information_schema') 
			AND pg_class.relkind IN ('r', 'm', 'p')
		ORDER BY
			pg_total_relation_size(pg_class.oid) DESC
	),
	per_schema AS (
		SELECT
			pg_namespace.nspname AS "object_schema",
			'N/A' AS "object_name",
			'N/A' AS "ojbect_kind",
			pg_size_pretty(SUM(pg_total_relation_size(pg_class.oid))) AS "total_size"
		FROM
			pg_class
		LEFT JOIN
			pg_namespace ON (pg_namespace.oid = pg_class.relnamespace)
		WHERE
			pg_namespace.nspname NOT IN ('pg_catalog', 'information_schema')
		GROUP BY 
			pg_namespace.nspname
	),
	per_kind AS (
		SELECT
			'N/A' AS "object_schema",
			'N/A' AS "object_name",
			CASE 
				WHEN pg_class.relkind = 'r' THEN 'ordinary table'
				WHEN pg_class.relkind = 'i' THEN 'index'
				WHEN pg_class.relkind = 'S' THEN 'sequence'
				WHEN pg_class.relkind = 't' THEN 'TOAST table'
				WHEN pg_class.relkind = 'v' THEN 'view'
				WHEN pg_class.relkind = 'm' THEN 'materialized view'
				WHEN pg_class.relkind = 'c' THEN 'composite type'
				WHEN pg_class.relkind = 'f' THEN 'foreign table'
				WHEN pg_class.relkind = 'p' THEN 'partitioned table'
				WHEN pg_class.relkind = 'I' THEN 'partitioned index'
			END AS "ojbect_kind",
			pg_size_pretty(SUM(pg_total_relation_size(pg_class.oid))) AS "total_size"
		FROM
			pg_class
		LEFT JOIN
			pg_namespace ON (pg_namespace.oid = pg_class.relnamespace)
		WHERE
			pg_namespace.nspname NOT IN ('pg_catalog', 'information_schema')
		GROUP BY 
			pg_class.relkind
	),
	total AS (
		SELECT
			'N/A' AS "object_schema",
			'N/A' AS "object_name",
			'N/A' AS "ojbect_kind",
			pg_size_pretty(SUM(pg_total_relation_size(pg_class.oid))) AS "total_size"
		FROM
			pg_class
		LEFT JOIN
			pg_namespace ON (pg_namespace.oid = pg_class.relnamespace)
		WHERE
			pg_namespace.nspname NOT IN ('pg_catalog', 'information_schema')
	)

-- SELECT * FROM total
-- UNION ALL 
-- SELECT * FROM per_schema
-- UNION ALL
SELECT * FROM table_sizes
-- UNION ALL SELECT * FROM per_kind;
```


## create a read-only access

```sql
-- SET ROLE rolname; -- assume role "rolname", always use object owner for GRANTS
-- SELECT current_user;  -- user name of current execution context
-- SELECT session_user;  -- session user name

-- example schema
CREATE SCHEMA example_schema;

-- example tables
CREATE TABLE example_schema.example_table (key TEXT PRIMARY KEY, value TEXT);
CREATE TABLE example_schema.example_another_table (key TEXT PRIMARY KEY, value TEXT);

-- application role
CREATE ROLE example_app_ro NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION INHERIT;
ALTER DEFAULT PRIVILEGES IN SCHEMA example_schema GRANT SELECT ON TABLES TO example_app_ro;
GRANT USAGE ON SCHEMA example_schema TO example_app_ro;
GRANT SELECT ON ALL TABLES IN SCHEMA example_schema TO example_app_ro;

-- example table read-only role
CREATE ROLE example_table_role_ro NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION INHERIT;
GRANT USAGE ON SCHEMA example_schema TO example_table_role_ro;
GRANT SELECT ON example_schema.example_table TO example_table_role_ro;

-- example another table read-only role
CREATE ROLE example_another_table_role_ro NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION INHERIT;
GRANT USAGE ON SCHEMA example_schema TO example_another_table_role_ro;
GRANT SELECT ON example_schema.example_another_table TO example_table_role_ro;

-- group role, granted example_table_role_ro and example_another_table_role_ro
CREATE ROLE example_group_ro NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION INHERIT;
GRANT example_table_role_ro TO example_group_ro;
GRANT example_another_table_role_ro TO example_group_ro;

-- user role, granted example_group_ro
CREATE ROLE example_user WITH NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION INHERIT LOGIN PASSWORD 'mysecretpassword' VALID UNTIL 'infinity';
GRANT example_group_ro TO example_user;
```


## inspect default schema privileges

```sql
SELECT
	pg_namespace.nspname AS "object_schema",
    case pg_default_acl.defaclobjtype
        when 'r' then 'TABLE'
        when 'm' then 'MATERIALIZED_VIEW'
        when 'i' then 'INDEX'
        when 'S' then 'SEQUENCE'
        when 'v' then 'VIEW'
        when 'c' then 'TYPE'
        else pg_default_acl.defaclobjtype::text
    end AS "object_type",
    pg_default_acl.defaclacl AS "default_acl"
FROM pg_default_acl
JOIN pg_namespace ON pg_default_acl.defaclnamespace = pg_namespace.oid;
```


## change ownership

```sql
SET ROLE old_owner;
REASSIGN OWNED BY old_owner TO new_owner;
```


## get user roles

```sql
 SELECT
	a.rolname AS "rolname",
	b.rolname AS "rolname_memberof"
FROM pg_roles AS a
INNER JOIN pg_roles AS b ON pg_has_role(a.rolname, b.oid, 'member')
GROUP BY a.rolname;
```


## run a postresql in docker

```bash
docker run --detach --name 'my-sgdb' \
    --volume ${PWD}/pgdata:/var/lib/postgresql/data \
    --publish 5432:5432 \
    --env POSTGRES_USER=myuser \
    --env POSTGRES_PASSWORD=mysecretpassword \
    --env POSTGRES_DB=mydatabase \
    postgres
```

```bash
docker exec -it 'my-sgdb' psql 'host=localhost user=myuser dbname=mydatabase'
```

```bash
docker run --rm -it postgres psql 'host=myhost user=myuser password=mysecretpassword dbname=mydatabase'
```

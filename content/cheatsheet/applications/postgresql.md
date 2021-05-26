---
title: postgresql
weight: 150
type: docs
bookCollapseSection: false
bookFlatSection: false
bookToc: true

---

## Check long running transactions

```sql
SELECT
	FORMAT('SELECTR pg_terminate_backend(%d)', pid) AS "run to kill",
	pid AS "process ID",
	usename AS "username",
	client_addr AS "source ip",
	EXTRACT(EPOCH FROM (DATE_TRUNC('second', now() - pg_stat_activity.query_start))) AS "duration in seconds",
	state as "state",
	TRIM(LEADING E'\n' FROM query) AS "query",  -- Adjusts query visualization in some softwares
FROM
	pg_stat_activity 
WHERE
	state != 'idle';
```
	

## show where a user has permissions

```sql
SELECT
	pg_tables.schemaname AS "schema_name",
	pg_tables.tablename AS "table_name",
	roles.kind AS "kind",
	roles.name AS "name",
	HAS_TABLE_PRIVILEGE(roles.name, pg_tables.schemaname || '.' || pg_tables.tablename, 'select') AS "select",
	HAS_TABLE_PRIVILEGE(roles.name, pg_tables.schemaname || '.' || pg_tables.tablename, 'insert') AS "insert",
	HAS_TABLE_PRIVILEGE(roles.name, pg_tables.schemaname || '.' || pg_tables.tablename, 'update') AS "update",
	HAS_TABLE_PRIVILEGE(roles.name, pg_tables.schemaname || '.' || pg_tables.tablename, 'delete') AS "delete",
	HAS_TABLE_PRIVILEGE(roles.name, pg_tables.schemaname || '.' || pg_tables.tablename, 'references') AS "references" 
FROM
	pg_tables,
	(
		SELECT 'role' AS kind, rolname AS name FROM  pg_roles 
		UNION
		SELECT 'user' AS kind, usename AS name FROM pg_user
	) AS roles
WHERE
	pg_tables.schemaname = 'public' AND
	pg_tables.tablename IN ('my_table', 'my_other_table') AND
	roles.name in ('app_production', 'app_ro', 'app_rw', 'root')
ORDER BY
	pg_tables.schemaname ASC,
	pg_tables.tablename ASC,
	roles.kind ASC,
	roles.name ASC;

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
FROM
	pg_class
JOIN
	pg_roles ON pg_roles.oid = pg_class.relowner
JOIN
	pg_namespace ON pg_namespace.oid = pg_class.relnamespace
WHERE
	pg_namespace.nspname NOT IN ('information_schema', 'pg_catalog')
	AND pg_namespace.nspname != 'pg_toast'
	AND pg_roles.rolname = current_user -- remove this if you want to see all objects
ORDER BY
	pg_namespace.nspname,
	pg_class.relname;
```

## show table sizes

```sql
SELECT
	pg_namespace.nspname AS "object_schema",
	pg_class.relname AS "object_name",
	pg_size_pretty(pg_total_relation_size(pg_class.oid)) AS "total_size"
FROM
	pg_class 
LEFT JOIN
	pg_namespace ON (pg_namespace.oid = pg_class.relnamespace)
WHERE
	pg_namespace.nspname NOT IN ('pg_catalog', 'information_schema')
	AND pg_class.relkind <> 'i'
	AND pg_namespace.nspname !~ '^pg_toast'
ORDER BY
	pg_total_relation_size(pg_class.oid) DESC;
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

### in redshit

```sql
CREATE GROUP "example_group_ro";
GRANT USAGE ON SCHEMA example_schema TO GROUP example_group_ro;
GRANT SELECT ON ALL TABLES IN SCHEMA example_schema TO GROUP example_group_ro;
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
FROM
    pg_default_acl
JOIN
    pg_namespace ON pg_default_acl.defaclnamespace = pg_namespace.oid;
```

## change ownership
```sql
SET ROLE old_owner;
REASSIGN OWNED BY old_owner TO new_owner;
```

## get user roles

```sql
 SELECT
	a.rolname,
	ARRAY_AGG(b.rolname)
FROM
	pg_roles a,
	pg_roles b
WHERE
	pg_has_role(a.rolname, b.oid, 'member')
GROUP BY
	a.rolname;
```

## redshift

```sql
-- Create a new user
CREATE USER example_user WITH PASSWORD 'mysecretpassword';

-- Add users to an existing group
ALTER GROUP example_group ADD USER example_user;

--- Query to check all groups a user is in
SELECT
	u.usename AS "rolname",
	u.usesuper AS "rolsuper",
	u.usecreatedb AS "rolcreatedb",
	u.valuntil AS "rolvaliduntil",
	ARRAY(
		SELECT
			g.groname
		FROM
			pg_catalog.pg_group g
		WHERE
			u.usesysid = ANY(g.grolist)
	) AS "memberof"
FROM
	pg_catalog.pg_user u
WHERE
	u.usename = 'YOUR_USERNAME_HERE'
ORDER BY
	rolname;

--- Query to list all users and schemas they have access
SELECT
	pg_user.usename,
	pg_namespace.nspname,
	has_schema_privilege ( pg_user.usename, pg_namespace.nspname, 'usage' ) 
FROM
	pg_user
CROSS
	JOIN pg_namespace 
WHERE
	pg_namespace.nspname NOT IN ( 'pg_internal', 'pg_toast', 'pg_catalog', 'admin' ) 
	AND pg_namespace.nspname NOT LIKE 'pg_temp_%' 
	AND pg_user.usename NOT IN ( 'yoda' ) 
	AND pg_user.usename NOT LIKE 'app_%';
```

## run a postresql in docker

```bash
docker run --detach --name my-sgdb \
    --volume ${PWD}/pgdata:/var/lib/postgresql/data \
    --publish 5432:5432 \
    --env POSTGRES_USER=myuser \
    --env POSTGRES_PASSWORD=mysecretpassword \
    --env POSTGRES_DB=mydatabase \
    postgres
```

```bash
docker exec -it my-sgdb \
    psql 'host=localhost user=myuser dbname=mydatabase'
```

```bash
docker run --rm -it postgres \
    psql 'host=myhost user=myuser password=mysecretpassword dbname=mydatabase'
```

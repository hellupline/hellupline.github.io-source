---
title: redshift
weight: 160
type: docs
bookCollapseSection: false
bookFlatSection: false
bookToc: true

---


## create user

```sql
CREATE USER "example_user" WITH PASSWORD 'mysecretpassword';
```


## create readonly group and add user

```sql
CREATE GROUP "example_group_ro";
GRANT USAGE ON SCHEMA "example_schema" TO GROUP "example_group_ro";
ALTER DEFAULT PRIVILEGES IN SCHEMA "example_schema" GRANT SELECT ON TABLES TO GROUP "example_group_ro";
GRANT SELECT ON ALL TABLES IN SCHEMA "example_schema" TO GROUP "example_group_ro";

ALTER GROUP "example_group_ro" ADD USER "my_user"
```


## locate schemas without `_ro` group

```sql
SELECT
	n.nspname
FROM
	pg_namespace AS n
WHERE
	n.nspname NOT IN ( 'pg_internal', 'pg_toast', 'pg_catalog', 'admin' )
	AND n.nspname NOT LIKE 'pg_temp_%'
	AND CONCAT (n.nspname, '_ro') NOT IN (SELECT pg_group.groname FROM pg_group)
ORDER BY
	n.nspname ASC;
```

```bash
SCHEMAS=(
	schema1
	schema2
)
for SCHEMA_NAME in ${SCHEMAS[@]}; do
	GROUP_NAME="${SCHEMA_NAME}_ro"
	echo "CREATE GROUP ${GROUP_NAME};"
	echo "GRANT USAGE ON SCHEMA ${SCHEMA_NAME} TO GROUP ${GROUP_NAME};"
	echo "ALTER DEFAULT PRIVILEGES IN SCHEMA ${SCHEMA_NAME} GRANT SELECT ON TABLES TO GROUP ${GROUP_NAME};"
	echo "GRANT SELECT ON ALL TABLES IN SCHEMA ${SCHEMA_NAME} TO GROUP ${GROUP_NAME};"
done
```


## user groups

```sql
SELECT
	u.usename AS "rolname",
	u.usesuper AS "rolsuper",
	u.usecreatedb AS "rolcreatedb",
	u.valuntil AS "rolvaliduntil",
    g.groname A "groname"
FROM
	pg_catalog.pg_user AS u
INNER JOIN
    pg_catalog.pg_group AS g ON u.usesysid = ANY(g.grolist)
ORDER BY
	rolname;
```


## user schemas
```sql
SELECT
	u.usename,
	n.nspname
FROM
	pg_user AS u
CROSS JOIN
    pg_namespace AS n
WHERE
	n.nspname NOT IN ('pg_internal', 'pg_toast', 'pg_catalog', 'admin', 'public')
	AND n.nspname NOT LIKE 'pg_temp_%'
	AND u.usename NOT IN ('admin')
	AND u.usename NOT LIKE 'app_%'
	AND has_schema_privilege (u.usename, n.nspname, 'usage')
ORDER BY
	u.usename ASC,
	n.nspname ASC;
```

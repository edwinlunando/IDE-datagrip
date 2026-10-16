SELECT pg_size_pretty(pg_database_size(current_database()));


SELECT
    relname AS table_name,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS total_size,
    pg_size_pretty(pg_relation_size(c.oid)) AS table_size,
    pg_size_pretty(pg_indexes_size(c.oid)) AS index_size
FROM
    pg_class c
LEFT JOIN
    pg_namespace n ON n.oid = c.relnamespace
WHERE
    n.nspname NOT IN ('pg_catalog', 'information_schema')
    AND c.relkind = 'r'
ORDER BY
    pg_total_relation_size(c.oid) DESC
LIMIT 30;

select * from hpp_funds;
select * from hpp_plannings order by id desc;
select * from transactions;

SELECT
    pg_size_pretty(AVG(pg_column_size(t.*))::bigint) AS avg_exact_row_size
FROM
    hpp_plannings t;

SELECT
    schemaname,
    tablename,
    SUM(avg_width) AS avg_row_payload_bytes,
    pg_size_pretty(SUM(avg_width)::bigint) AS avg_row_payload_pretty
FROM
    pg_stats
WHERE
    schemaname NOT IN ('pg_catalog', 'information_schema')
GROUP BY
    schemaname,
    tablename
ORDER BY
    SUM(avg_width) DESC;

SELECT
    schemaname,
    relname AS tablename,
    n_live_tup AS row_count,
    pg_size_pretty(pg_relation_size(relid)) AS total_table_size,
    CASE
        WHEN n_live_tup > 0
        THEN pg_size_pretty((pg_relation_size(relid) / n_live_tup)::bigint)
        ELSE '0 bytes'
    END AS avg_row_size_on_disk
FROM
    pg_stat_user_tables
ORDER BY
    pg_relation_size(relid) DESC;
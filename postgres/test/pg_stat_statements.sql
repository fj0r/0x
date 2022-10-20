create extension if not exists pg_stat_statements;
SELECT substring(query, 1, 30) AS query
     , calls
     , round(total_exec_time::numeric, 2) AS total_time
     , round(mean_exec_time::numeric, 2) AS mean_time
     , round((100 * total_exec_time / sum(total_exec_time) OVER ())::numeric, 2) AS percentage
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 10;

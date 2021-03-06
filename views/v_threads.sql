#
# Name: v$threads
# Author: YJ
# Date: 2016.06.27
# Desc: show current all threads
#
# MariaDB [sys]> select * from v$threads;
# +-----------+-------------------------------+-------------+---------------+------------+-------------+-----------------------------+-------------------------+---------------+--------+-------------------+---------------+------------+------------+-----------+
# | thread_id | user                          | schema_name | thread_status | thread_sec | memory_used | thread_state                | thread_info             | trx_existence | trx_id | trx_rows_modified | lock_wait_sec | lock_table | lock_index | lock_type |
# +-----------+-------------------------------+-------------+---------------+------------+-------------+-----------------------------+-------------------------+---------------+--------+-------------------+---------------+------------+------------+-----------+
# |       368 | `root`@`localhost`            | sys         | Query         |          0 |      844672 | Filling schema table        | select * from v$threads | NO            | NULL   |              NULL |          NULL | NULL       | NULL       | NULL      |
# ...
# |         2 | `event_scheduler`@`localhost` | NULL        | Daemon        |        149 |       44280 | Waiting for next activation | NULL                    | NO            | NULL   |              NULL |          NULL | NULL       | NULL       | NULL      |
# +-----------+-------------------------------+-------------+---------------+------------+-------------+-----------------------------+-------------------------+---------------+--------+-------------------+---------------+------------+------------+-----------+
#
CREATE OR REPLACE
ALGORITHM=UNDEFINED 
DEFINER = 'root'@'localhost'
SQL SECURITY INVOKER
VIEW `v$threads`
AS
SELECT p.id AS thread_id
      ,concat('`', p.user, '`@`', substring_index(p.host, ':', 1), '`') AS user
      ,p.db AS schema_name
      ,p.command AS thread_status
      ,p.time AS thread_sec
      ,p.memory_used
      ,p.state AS thread_state
      ,p.info AS thread_info
      ,if(trx.trx_state is not null, 'YES', 'NO') AS trx_existence
      ,trx.trx_id
      ,trx.trx_rows_modified
      ,timestampdiff(SECOND, trx.trx_wait_started, now()) AS lock_wait_sec
      ,locks.lock_table
      ,locks.lock_index
      ,locks.lock_type
  FROM information_schema.processlist p
  LEFT JOIN information_schema.innodb_trx trx
    ON p.id = trx.trx_mysql_thread_id
  LEFT JOIN information_schema.innodb_locks locks
    ON trx.trx_id = locks.lock_trx_id
;

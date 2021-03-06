#
# require plugin "metadata_lock_info"
#
# Name: v$meta_lock
# Author: YJ
# Date: 2016.06.27
# Desc: show current metadata lock info
#
# MariaDB [sys]> select * from v$meta_lock;
# +-------------+-------------------+-----------------+------------------+--------------------+-----------+--------------------+---------------+-----------------+---------------------------+-------------+
# | schema_name | object_name       | meta_lock_type  | meta_lock_mode   | meta_lock_duration | thread_id | user               | thread_status | thread_time_sec | thread_info               | kill_thread |
# +-------------+-------------------+-----------------+------------------+--------------------+-----------+--------------------+---------------+-----------------+---------------------------+-------------+
# | sys         | v$meta_lock       | Table           | MDL_SHARED_READ  | MDL_TRANSACTION    |    303860 | root@localhost     | Query         |               0 | select * from v$meta_lock | KILL 303860 |
# +-------------+-------------------+-----------------+------------------+--------------------+-----------+--------------------+---------------+-----------------+---------------------------+-------------+
#
CREATE OR REPLACE
ALGORITHM=UNDEFINED 
DEFINER = 'root'@'localhost'
SQL SECURITY INVOKER
VIEW `v$meta_lock`
AS
SELECT meta.table_schema AS schema_name
      ,meta.table_name AS object_name
      ,REPLACE(meta.lock_type, ' metadata lock', '') AS meta_lock_type
      ,meta.lock_mode AS meta_lock_mode
      ,meta.lock_duration AS meta_lock_duration
      ,ps.id AS thread_id
      ,concat(ps.user, '@', substring_index(ps.host, ':', 1)) AS user
      ,ps.command AS thread_status
      ,ps.time AS thread_time_sec
      ,info AS thread_info
      ,concat('KILL ', ps.id) as kill_thread
  FROM information_schema.metadata_lock_info meta
  LEFT OUTER JOIN information_schema. processlist ps
    ON meta.thread_id = ps.id
;

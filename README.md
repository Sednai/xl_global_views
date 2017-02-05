# xl_global_views

Postgres-XL Global Views extension
====================

xl_global_views is an extension to create global views from number of system tables aggregated from all nodes (both coordinators and datanodes).
Each view has two additional columns prepend node_name and node_type. 
The extension uses _execute direct_ construct, be usre you use the XL version with a patch [https://git.postgresql.org/gitweb/?p=postgres-xl.git;a=commit;h=1b6ada225da45c82529d56f71e3c6a62fabcfd55] that addresses limitation of using cursors based on _execute direct_. Without this patch most of the views will not work and report SPI errors.

INSTALLATION
------------
Requirement: PostgreSQL-XL.
Extension is installed in the public schema and is not relocatable.

    CREATE EXTENSION xl_global_views ;

_EXECUTE DIRECT_ requires superuser role for now, so the global views.

The views created now are:
pgxl_locks                     pgxl_stat_bgwriter             pgxl_statio_all_tables         pgxl_statio_user_sequences     pgxl_stat_ssl                  pgxl_stat_user_tables
pgxl_stat_activity             pgxl_stat_database             pgxl_statio_sys_indexes        pgxl_statio_user_tables        pgxl_stat_sys_indexes          pgxl_stat_xact_all_tables
pgxl_stat_all_indexes          pgxl_stat_database_conflicts   pgxl_statio_sys_sequences      pgxl_statistic                 pgxl_stat_sys_tables           pgxl_stat_xact_sys_tables
pgxl_stat_all_tables           pgxl_statio_all_indexes        pgxl_statio_sys_tables         pgxl_stat_replication          pgxl_stat_user_functions       pgxl_stat_xact_user_functions
pgxl_stat_archiver             pgxl_statio_all_sequences      pgxl_statio_user_indexes       pgxl_stats                     pgxl_stat_user_indexes         pgxl_stat_xact_user_tables

EXAMPLE
-------

	select * from pgxl_statio_all_tables where node_type = 'D' and relname = 'pg_class' limit 10;

node_name | node_type | relid | schemaname | relname  | heap_blks_read | heap_blks_hit | idx_blks_read | idx_blks_hit | toast_blks_read | toast_blks_hit | tidx_blks_read | tidx_blks_hit
-----------+-----------+-------+------------+----------+----------------+---------------+---------------+--------------+-----------------+----------------+----------------+---------------
 datanode1 | D         |  1259 | pg_catalog | pg_class |           3918 |      58604308 |           259 |      3035480 |          [null] |         [null] |         [null] |        [null]
 datanode2 | D         |  1259 | pg_catalog | pg_class |           3745 |       2634617 |           613 |       141135 |          [null] |         [null] |         [null] |        [null]
 datanode3 | D         |  1259 | pg_catalog | pg_class |           3742 |        965008 |           395 |        41040 |          [null] |         [null] |         [null] |        [null]
 datanode4 | D         |  1259 | pg_catalog | pg_class |           3722 |        937601 |           212 |        37620 |          [null] |         [null] |         [null] |        [null]
 datanode5 | D         |  1259 | pg_catalog | pg_class |           3918 |      58604308 |           259 |      3035480 |          [null] |         [null] |         [null] |        [null]
 datanode6 | D         |  1259 | pg_catalog | pg_class |           3745 |       2634617 |           613 |       141135 |          [null] |         [null] |         [null] |        [null]
 datanode7 | D         |  1259 | pg_catalog | pg_class |           3742 |        965008 |           395 |        41040 |          [null] |         [null] |         [null] |        [null]
 datanode8 | D         |  1259 | pg_catalog | pg_class |           3722 |        937601 |           212 |        37620 |          [null] |         [null] |         [null] |        [null]
(8 rows)

	

LICENSE AND COPYRIGHT
---------------------

XL Global views extension is released under the PostgreSQL License, a liberal Open Source license, similar to the BSD or MIT licenses.

Krzysztof Nienartowicz & Pavan Deolasee, 2017.

Permission to use, copy, modify, and distribute this software and its documentation for any purpose, without fee, and without a written agreement is hereby granted, provided that the above copyright notice and this paragraph and the following two paragraphs appear in all copies.

IN NO EVENT SHALL THE AUTHOR BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE AUTHOR HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

THE AUTHOR SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND THE AUTHOR HAS NO OBLIGATIONS TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.


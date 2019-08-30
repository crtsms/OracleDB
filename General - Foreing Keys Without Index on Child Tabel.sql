--This scritp get all foreing keys that not have index on child table
--Its important to have index in both directions, parent and child table

WITH my_user_cons_columns AS
   (SELECT table_name,
      constraint_name,
      column_name,
      position
   FROM user_cons_columns
   ),
   my_user_ind_columns AS
   (SELECT table_name,
      index_name,
      column_name,
      column_position
   FROM user_ind_columns
   )
SELECT parent_table  AS "Parent Table",
   parent_columns    AS "Parent Columns",
   parent_constraint AS "Parent Constraint",
   delete_rule       AS "On delete",
   child_constraint  AS "Child Constraint",
   child_table       AS "Child Table",
   child_columns     AS "Unindexed Child Columns"
FROM
   (SELECT table_name                 AS parent_table,
      cons_columns                    AS parent_columns,
      constraint_name                 AS parent_constraint,
      connect_by_root delete_rule     AS delete_rule,
      connect_by_root constraint_name AS child_constraint,
      connect_by_root table_name      AS child_table,
      connect_by_root cons_columns    AS child_columns
   FROM
      (SELECT table_name,
         constraint_name,
         MAX (SUBSTR (sys_connect_by_path (column_name, ','), 2)) cons_columns
      FROM my_user_cons_columns
         START WITH position = 1
         CONNECT BY position = prior position + 1
         AND table_name      = prior table_name
         AND constraint_name = prior constraint_name
      GROUP BY table_name,
         constraint_name
      )
   JOIN user_constraints USING (table_name, constraint_name)
   WHERE level                           = 2
      CONNECT BY nocycle constraint_name = prior r_constraint_name
   )
LEFT JOIN
   (SELECT table_name,
      MAX (SUBSTR (sys_connect_by_path (column_name, ','), 2)) index_columns
   FROM my_user_ind_columns
      START WITH column_position = 1
      CONNECT BY column_position = prior column_position + 1
      AND table_name             = prior table_name
      AND index_name             = prior index_name
   GROUP BY table_name,
      index_name
   )
ON (child_table                             = table_name
   AND instr (index_columns, child_columns) = 1)
WHERE table_name   IS NULL
ORDER BY 1,
   2,
   3;
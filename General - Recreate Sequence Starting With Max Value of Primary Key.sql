--This scritp find an existing sequence alredy created to Primary Key column, drop if exist,
--and recreate with starting value the max value of the Primary Key. Pay attention that it uses 
--a convention to name the sequence. The current scritp do not work with a composite primary key

create or replace procedure USEREXAMPLE.SP_SEQUENCE(p_table varchar2) AUTHID CURRENT_USER AS
  v_sql_stmt            varchar2(2000);
  v_sequence_exist      integer;
  v_sequence_start      integer;
  v_column              varchar2(30);
  v_qtd_column          integer;

BEGIN
    --get the primary key column from table and determine if the PK is based on only one field
    v_sql_stmt := '
    SELECT cols.column_name,
           (select count(1) from all_cons_columns x where x.constraint_name = cols.constraint_name) qtd
      FROM all_constraints cons, all_cons_columns cols
     WHERE cols.table_name = ' || '''' || p_table || '''' || '
       AND cons.constraint_type = ''P''
       AND cons.constraint_name = cols.constraint_name
       AND cons.owner = cols.owner
       AND cols.position = 1
       AND cons.status = ''ENABLED'' ';
    EXECUTE IMMEDIATE v_sql_stmt INTO v_column, v_qtd_column;
     
    IF(v_qtd_column > 1) then
        raise_application_error( -20001, 'There are two column defined as Primary Key oh the table. This function isn´t avaible for composite Primary Key');
    END IF;
 
    --get max id from table    
    v_sql_stmt := 'SELECT CASE WHEN MAX('||v_column||') IS NULL THEN 1 ELSE MAX('||v_column||') + 1 END FROM '||p_table||'';
    EXECUTE IMMEDIATE v_sql_stmt INTO v_sequence_start;

    -- try to find sequence in data dictionary
    v_sql_stmt := 'SELECT COUNT(1) FROM all_sequences WHERE sequence_name =' || '''' || 'SQ_' || p_table ||'''';
    EXECUTE IMMEDIATE v_sql_stmt INTO v_sequence_exist;
	
	IF(v_sequence_exist > 0) THEN
	
	    -- if sequence found, drop it
		v_sql_stmt := 'DROP SEQUENCE SQ_' || p_table || '';
		EXECUTE IMMEDIATE v_sql_stmt;
	
	END IF;
	
	v_sql_stmt := 'CREATE SEQUENCE SQ_'|| p_table || ' start with ' || v_sequence_start || ' increment by 1';
	EXECUTE IMMEDIATE v_sql_stmt;
    
END;
/
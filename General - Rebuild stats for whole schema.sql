--This script generate a refreshed stats for a whole schema
--passed by parameter. Possible to run more than one schema.

BEGIN
    FOR rec IN (SELECT * 
                FROM all_users
                WHERE username IN ('SCHEMA1','SCHEMA2'))
    LOOP
        dbms_stats.gather_schema_stats(rec.username);
    END LOOP;
END;
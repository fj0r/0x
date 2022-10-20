CREATE EVENT TRIGGER on_create_table ON ddl_command_end
    WHEN TAG IN ('CREATE TABLE')
EXECUTE PROCEDURE on_create_table_func();
-- run file: /pg_create_table_end/public.xxx.sql
CREATE OR REPLACE FUNCTION on_create_table_func() RETURNS event_trigger AS
$$
declare
    r    record;
    file text;
BEGIN
    r := pg_event_trigger_ddl_commands();
    file := '/pg_create_table_end/' || r.object_identity || '.sql';
    if not pg_stat_file(file, true) is null then
        execute pg_read_file(file);
    end if;
END
$$ LANGUAGE plpgsql;

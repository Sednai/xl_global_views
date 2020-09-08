-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION xl_global_views" to load this file. \quit

CREATE FUNCTION public.pgxl_global_view(localTable text, fields text) RETURNS  setof record  AS 
$_$
DECLARE
	qry text;
	r record;
	rdirect record;
BEGIN
	for r in (select * from pgxc_node where node_type in ('C','D'))
	loop
	    	qry := 'EXECUTE DIRECT ON (' || r.node_name || ') ' || '$E$ SELECT ''' || r.node_name ||'''::text,'''|| r.node_type ||'''::text,* from '|| $1 || '$E$';
	    	FOR rdirect in EXECUTE qry LOOP
	    	  return next rdirect;
	    	end loop;
	end loop;
    return;    
END
$_$ LANGUAGE plpgsql;
COMMENT ON FUNCTION pgxl_global_view(localTable text, fields text) is 'xl_global_views function to fetch data from all the nodes of the XL cluster, prefixing them with node_name and node_type.';

-- create public views for anything that starts with pg_stat, omit anyarray
CREATE FUNCTION public.pgxl_create_views() returns void as  
$_$
declare
    r record;
begin
for r in (
    select table_name, regexp_replace(table_name, '^pg_', 'pgxl_') xl_table_name,
    'create view public.'
    || regexp_replace(table_name, '^pg_', 'pgxl_')
    || ' as select  node_name, node_type,' || array_to_string(array_agg(column_name::text order by ordinal_position), ',' )
    || ' from public.pgxl_global_view(''' || table_name || '''::text,''' ||array_to_string(array_agg(column_name::text order by ordinal_position),',')
    || '''::text) as (node_name text, node_type text,'
    || array_to_string(array_agg(column_name || ' '|| case when udt_name = 'char' then replace(udt_name, 'char', '"char"') when udt_name = '_char' then replace(udt_name, '_char', '"_char"') else udt_name end order by ordinal_position), ', ') || ');'  stmt
    from information_schema.columns c
        where  (table_name ~ 'pg_stat|pr_prepared' or table_name='pg_locks' or table_name = ANY(ARRAY['pg_class','pg_type']) ) 
        and table_name !~ 'pgxl_'
          and udt_name != 'anyarray' and udt_name != 'pg_node_tree'
    group by 1,2
    )
    loop
        execute format('drop view if exists public.%s;',r.xl_table_name);
        execute r.stmt;
        execute format('grant select on public.%s to public;',r.xl_table_name);
    end loop;
end
$_$ language plpgsql;
COMMENT ON FUNCTION public.pgxl_create_views() is 'xl_global_views function to define global views.';
-- select public.pgxl_create_views();


rem
rem	Script:		plan_run81.sql
rem	Author:		Jonathan Lewis
rem	Dated:		1991 (original)
rem	Purpose:	Framework for Explain Plan. Version 8 only
rem
rem	Usage:
rem	Write an SQL statement into a script called target.sql. This statement
rem	should start on the first line of the file and end with a semi-colon.
rem	Then execute plan_run81.sql
rem
rem	Preparation:
rem	============
rem	Connect to the SYSTEM (or other suitably privileged) account 
rem	Copy the $ORACLE_HOME/rdbms/admin/utlxplan.sql
rem	Change the CREATE TABLE statement to CREATE GLOBAL TEMPORARY TABLE
rem	Add the lines (if needed):
rem		create public synonym plan_table for plan_table
rem		grant all on plan_table to public		
rem		Execute the script plan_walk8.sql
rem
rem	Notes:
rem	======
rem	The mechanisms, table, and functionlity of explain plan keeps changing with
rem	version of Oracle. The changes from v8 to v9 were the most extreme, which
rem	is why there are now two versions of the script.
rem
rem	When you call plan_run81, it will (try to) explain the plan into the default
rem	table PLAN_TABLE, and then produce a report from that table. 
rem
rem	The plan_run81.sql script can be kept in a centralised location, as it invokes
rem	the TARGET.SQL script using the '@' notation - which means TARGET.SQL will
rem	be located in the 'current working subdirectory' rather than the directory
rem	that holds the plan_run81.sql script. 
rem
rem	The report comes from a "simple" SQL statement in the traditional execution
rem	path style, similar to AUTOTRACE and tkprof layout, but with the secondary 
rem	(e.g. remote, or PX slave) SQL listed after the main report. 
rem
rem	All outputs are sent to file, whose name is the current session id (audsid 
rem	or sys_context('userenv','sessionid') value). This value is quoted at the
rem	start and end of run.
rem
rem	At the end of the report section, the script should issue:
rem		truncate table system.plan_table 
rem	This action is based on the assumption you have used a GTT, and that the 
rem	plan_table is owned by SYSTEM.
rem
rem	Special Note:
rem	=============
rem	In Oracle version 9, "Subquery factoring" introduced the biggest change
rem	A factored subquery creates and populates a global temporary table, and 
rem	the SQL to populate the table is also explained into the plan_table using 
rem	a recursive, autonomous, transaction.
rem	This sub-plan has a statement_id of SYS_LE_nnn_mmm, where the NNN is the line
rem	number (id) of the plan_table where the recursion took place.
rem
rem

start setenv

set autotrace off
set linesize 180
set verify off

set def =
set def &

rem
rem	Some of these formatting values are echoed in the explain_plan package
rem	so that the three sets of output line up nicely.
rem

column plan		format a160	heading 'Plan'
column id	 	format 999	heading 'Id'
column parent_id 	format 999	heading 'Par'
column position 	format 999	heading 'Pos'
column object_instance 	format 999	heading 'Ins'

column state_id new_value m_statement_id
select userenv('sessionid') state_id from dual;

explain plan
set statement_id = '&m_statement_id'
for
@target

set feedback off
spool &m_statement_id

select
	id,
	parent_id,
	position,
	object_instance,
	rpad(' ',2*level) ||
	operation || ' ' ||
	decode(optimizer,null,null,
		'(' || lower(optimizer) || ') '
	)  ||
	object_type || ' ' ||
	object_owner || ' ' ||
	object_name || ' ' ||
	decode(options,null,null,'('||lower(options)||') ') ||
	other_tag || ' ' ||
	decode(partition_id,null,null,
		'Pt id: ' || partition_id || ' '
	)  ||
	decode(partition_start,null,null,
		'Pt Range: ' || partition_start || ' - ' ||
		partition_stop || ' '
	) ||
	decode(distribution,null,null, 
		'Distribution: ' || distribution || ' '
	) ||
	decode(cost,null,null,
		'Cost (' || cost || ',' || cardinality || ',' || bytes || ') ' 
	) ||
	decode(search_columns, null,null,
		'(Columns ' || search_columns || ') '
	)  							plan
from
	plan_table
start with
		id = 0 
	and	statement_id = '&m_statement_id'
connect by
		(	parent_id = prior id
		 and	statement_id = prior statement_id
		)
	or
		( 	id = 0
		 and	prior nvl(object_name, ' ') like 'SYS_LE%' 
		 and	nvl(statement_id, ' ') = prior nvl(object_name, ' ')
		)
order by id
;

rem	*****************************************
rem
rem	Dump remote code, PQ slave code etc. but 
rem	only for lines which have something there
rem
rem	*****************************************

select
	id, object_node, other
from
	plan_table
where
	statement_id = '&m_statement_id'
and	other is not null
order by
	id;

select id, remarks 
from plan_table
where remarks is not null
;

rem	*************************************
rem
rem	Now call explain_plan.plan_walk
rem	to do the alternative display
rem
rem	Version 0, the format is recursive descent
rem	Version 1, the format is (nearly) traditional
rem
rem	*************************************

set serveroutput on size 1000000 format wrapped

execute explain_plan8.plan_walk('&m_statement_id',0)
execute explain_plan8.plan_walk('&m_statement_id',1)

spool off

rem
rem	Use the truncate if you have a private, 
rem	permanent plan_table. This is good if 
rem	you have to worry about recursive SQL
rem

rem	truncate table system.plan_table;

rem
rem	Use the delete if you have a public
rem	permanent plan_table.  It is less 
rem	efficient, but cleans up the mess.
rem
rem	If the table is a GTT with ON COMMIT,
rem	then the data will disappear when we
rem	terminate the session anyway.
rem

delete from plan_table 
where statement_id = '&m_statement_id';

rem
rem	Thanks to recursive SQL for temp tables, you need to do this
rem

delete from plan_table;
commit;

prompt
prompt Output file is &m_statement_id..lst
prompt


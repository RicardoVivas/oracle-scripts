set lin 300
col name format a15
select group_number, name,disk_number, mount_status, header_status, mode_status, state,redundancy, total_mb, free_mb from v$asm_disk;
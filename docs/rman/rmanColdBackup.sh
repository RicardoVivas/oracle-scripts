#!/bin/sh

. /usr/orahome/warwick/backup/backupEnv.sh

cat $ORATAB | while read LINE
do

ORACLE_SID=`echo $LINE | awk -F: '{print $1}'`
export ORACLE_SID

ORACLE_HOME=`echo $LINE | awk -F: '{print $2}'`
export ORACLE_HOME


PATH=$ORACLE_HOME/bin:$PATH
export PATH

logfile=$backupBase/logs/rmanBackup-$ORACLE_SID-$today.log

targetString="connect target / "
if [ "$repoString" != "" ]; then
repoString="connect catalog $repoString"
fi

fileFormat="$backupBase/$ORACLE_SID/rman/df_%d_%s_%p";
controlFileFormat="$backupBase/$ORACLE_SID/rman/cf_%F";

$ORACLE_HOME/bin/rman  log=$logfile << BACKUP
$targetString $repoString
shutdown immediate;
startup mount;
CONFIGURE CONTROLFILE AUTOBACKUP ON;
configure controlfile autobackup format  for device type disk to '$controlFileFormat';
backup database format '$fileFormat' maxsetsize 2000M;
alter database open;
report obsolete;
delete force noprompt obsolete;
BACKUP

done

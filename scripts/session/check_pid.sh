#! /bin/sh

###################################################################################
#
# This script is intent to find out what a connection is doing quickly
#  If no trace file is generated, then the session is inactive in the sample time
#
###################################################################################
 
# Check parameters :   interval (seconds),pid
if [ $# != 2 ]; then
echo "Input 3 parameters : interval (seconds), pid"
exit 0;
fi


thisMoment=$2_`date '+%m-%d-%H-%M-%S'`
sqlFile=/tmp/$thisMoment.sql
outPut=/tmp/$thisMoment.txt 
sidFile=/tmp/$thisMoment.sid
workDir=/home/staff/cu/scab/dba/trace
traceFile=/usr/oraadmin/udump/`cat /var/opt/oracle/oratab |cut  -f1 -d:`_ora_$2.trc

# get sid from pid

/usr/orahome/bin/sqlplus  /nolog @$workDir/pid_diagnostic_sid.sql $2 $sidFile
sid=`cat $sidFile | cut -f1 -d:`
if [ "$sid" = "" ]; then
 echo "I canot find coresponding session to that pid."
 exit
fi
serial_number=`cat $sidFile | cut -f2 -d:`
username=`cat $sidFile | cut -f3 -d:`
osuser=`cat $sidFile | cut -f4 -d:`
machine=`cat $sidFile | cut -f5 -d:`
program=`cat $sidFile | cut -f6 -d:`
logon_time=`cat $sidFile | cut -f7 -d:`

echo "----------------------------------------------------------"
echo sid, serial_number is:  $sid:$serial_number
echo user name, osuser is:   $username   $osuser
echo machine is : $machine
echo program,logon_time is :  $program:$logon_time
echo "----------------------------------------------------------"

# start trace

/usr/orahome/bin/sqlplus  /nolog @$workDir/pid_diagnostic_trace $sid $serial_number TRUE 

echo "sleep $1 seconds ..."
sleep  $1

# stop trace
/usr/orahome/bin/sqlplus  /nolog @$workDir/pid_diagnostic_trace $sid $serial_number FALSE 

if [ -f $traceFile ]; then
# tkprof
echo "about to tkprof $traceFile"

/usr/orahome/bin/tkprof  $traceFile $outPut sys=no  aggregate=no  record=$sqlFile 


echo "Check sql: $sqlFile  and output : $outPut"

else
echo "$traceFile does not exist. "
echo "Maybe no activity in sample period. Maybethe tracefile name are like 'sid_j00_pid'. Check bdump directory and manually run tkprof"
fi

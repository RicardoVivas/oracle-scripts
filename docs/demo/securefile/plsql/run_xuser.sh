#!/bin/ksh
#
# $Header: run_xuser.sh 22-mar-2007.23:40:55 vdjegara Exp $
#
# run_xuser.sh
#
# Copyright (c) 2007, Oracle. All rights reserved.  
#
#    NAME
#      run_xuser.sh - <one-line expansion of the name>
#
#    DESCRIPTION
#      <short description of component this file declares/defines>
#
#    NOTES
#      <other useful comments, qualifications, etc.>
#
#    MODIFIED   (MM/DD/YY)
#    vdjegara    03/22/07 - Securefile multiuser demo script
#    vdjegara    03/22/07 - Creation
#

if [ $# -le 1 ]; then
  echo "Usage run_xuser.sh <numUsers> <newspc|reuse> (e.g run_xuser.sh 4 newspc)";
  exit;
fi

newspc=0;
reuse=0;

NumUsers=$1
SpcArg=$2

if [ $NumUsers -le 0 ]; then
  echo "Invalid or number of users to run is =< 0";
  exit ;
fi

if [ "$SpcArg" = "newspc" ]; then
  newspc=1;
elif [ "$SpcArg" = "reuse" ]; then
  reuse=1;
else
  echo "Second argument $SpcArg is invalid ";
  echo "Values allowed are: newspc or reuse (case sentitive)";
  exit;
fi

echo " "
echo "Cleaning old log files.."
echo " "
rm -f basicfile*.log basicfile*.info  basicfile*.nsp
rm -f securefile*.log securefile*.info securefile*.nsp

echo "-------------------------------------------"

# FOR LOOP FOR LOBSIZES
for lobsize in 10240 102400 1024000 10240000 102400000
do
   if [ ${lobsize} -eq 10240 ] ; then
     commitsize=100
     let iter=1000/NumUsers;
   elif [ ${lobsize} -eq 102400 ] ; then
     commitsize=10
     let iter=1000/NumUsers;
   elif [ ${lobsize} -eq 1024000 ] ; then
     commitsize=10
     let iter=100/NumUsers;
   elif [ ${lobsize} -eq 10240000 ] ; then
     commitsize=1
     let iter=100/NumUsers;
   elif [ ${lobsize} -eq 102400000 ] ; then
     commitsize=1
     let iter=10/NumUsers;
   else
      echo "Invalid lobsize.."
      exit
   fi

   if [ $iter -le 1 ] ; then 
    echo "PARAMETER (iter) ERROR..."
    echo "Iter. is less than or equal to 1 for lobsize ${lobsize}"
    echo "Test for Lobsize size ${lobsize} is not run.."
    echo "Please edit run_xuser.sh to increase iter. and run again.."
    echo "    "
    exit
  fi
 
   echo "Starting $lobsize bytes insert/select test.."

# FOR LOOP FOR LOBTYPES basicfile and securefile
   for lobtype in basicfile securefile
   do
      echo "Dropping table foo and recreating it.."
      echo " "
      if [ $reuse -eq 1 ]; then 
        sqlplus -s lob_demo/lob_demo @cr_tab.sql $lobtype NONE >${lobtype}_${lobsize}.info
      else
        sqlplus -s lob_demo/lob_demo @cr_tab.sql $lobtype AUTO >${lobtype}_${lobsize}.info
      fi

# NEW SPACE TEST
      echo "Starting $lobtype insert (newspace) test.."

      UserCount=1;
      while [ $UserCount -le $NumUsers ]
      do
        echo "Starting user $UserCount .."
        echo "--Starting Insert test-- " >>${lobtype}_${lobsize}_${UserCount}.log
        sqlplus -s lob_demo/lob_demo <<! >>${lobtype}_${lobsize}_${UserCount}.log &
        set feedback off
        set serveroutput on
        exec LocatorAPI_Insert($lobsize, $commitsize, $iter, $UserCount);
!
        let UserCount=UserCount+1;
      done

      echo "Waiting for Insert (newspace) jobs to finish.."
      wait
      echo "Insert jobs finished"
      echo " "
     
# REUSE TEST 
      if [ $reuse -eq 1 ]; then
      
        echo "Collecting space used and deleting all rows from foo.."
        echo "Space used before deletion .." >>${lobtype}_${lobsize}.info

        sqlplus -s lob_demo/lob_demo <<! >>${lobtype}_${lobsize}.info
          set pagesize 60
 	  set linesize 80
 	  col segment_name format a30
          select segment_name, segment_type, sum(bytes)/1024/1024 Size_Mb 
          from user_segments where segment_name='FOO_DOCUMENT_LOBSEG' 
          group by segment_name, segment_type;
	
	  delete from foo ;
	  commit;
!
        echo "Moving newspc result files to .nsp (new space) extension.."
        for i in `ls ${lobtype}_${lobsize}_*.log`
        do
         mv $i $i.nsp
        done

        echo "Sleeping 15 seconds for retention time to expire.."
        echo " "
        sleep 15

        echo "Starting $lobtype insert (reuse space) test.."
        UserCount=1;
        while [ $UserCount -le $NumUsers ]
        do
         echo "Starting user $UserCount .."
         sqlplus -s lob_demo/lob_demo <<! >>${lobtype}_${lobsize}_${UserCount}.log &
           set feedback off
           set serveroutput on
           exec LocatorAPI_Insert($lobsize, $commitsize, $iter, $UserCount);
!
         let UserCount=UserCount+1;
        done

        echo "Waiting for Insert (space reuse) jobs to finish.."
        wait
        echo "Insert jobs finished"
        echo " "
        echo "Collecting space used after space reuse test."
        echo "Space used after reuse test.." >>${lobtype}_${lobsize}.info

        sqlplus -s lob_demo/lob_demo <<! >>${lobtype}_${lobsize}.info
          set pagesize 60
          set linesize 80
          col segment_name format a30
          select segment_name, segment_type, sum(bytes)/1024/1024 Size_Mb
          from user_segments where segment_name='FOO_DOCUMENT_LOBSEG'
          group by segment_name, segment_type;
!
        echo "Check ${lobtype}_${lobsize}.info file for space used details"
        echo " "
      fi

# READ TEST 
      echo "Starting $lobtype select test.."
      UserCount=1;
      while [ $UserCount -le $NumUsers ]
      do
        echo "Starting user $UserCount .."
        echo "--Starting Select test-- " >>${lobtype}_${lobsize}_${UserCount}.log
        sqlplus -s lob_demo/lob_demo <<! >>${lobtype}_${lobsize}_${UserCount}.log &
        set feedback off
        set serveroutput on
        exec LocatorAPI_Select($lobsize, $commitsize, $iter, $UserCount);
!
        let UserCount=UserCount+1;
      done
      echo "Waiting for Select jobs to finish.."
      wait
      echo "Select jobs finished"
      echo " "

      echo "Finished ${lobtype} test for size=$lobsize .."
      echo "Check ${lobtype}_${lobsize}_*.log for results.."
      echo " "
   done
done

ERRORCNT=`grep ORA- *.log |wc -l`
if [ $ERRORCNT != 0 ]; then
   echo "There were some Oracle errors during the run "
   echo "Please check *.log and *.nsp files for details"
   echo "Following report may not be correct or give error"
   echo " " 
fi


echo "Running perl script to generate report (assuming perl is in /usr/bin/perl)"

if [ $reuse -eq 1 ]; then
  echo " \n";
  echo 			"RESULTS ARE FOR REUSE SPACE TEST ";
  echo " \n";
else
  echo " \n";
  echo 			"RESULTS ARE FOR NEW SPACE TEST ";
  echo " \n";
fi

genrep.pl $NumUsers 
echo " \n";


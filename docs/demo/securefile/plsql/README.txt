/
/ $Header: README.txt 22-mar-2007.13:39:46 vdjegara Exp $
/
/ README.txt
/
/ Copyright (c) 2007, Oracle. All Rights Reserved.
/
/   NAME
/     README.txt - <one-line expansion of the name>
/
/   DESCRIPTION
/     <short description of component this file declares/defines>
/
/   NOTES
/     <other useful comments, qualifications, etc.>
/
/   MODIFIED   (MM/DD/YY)
/   vdjegara    01/29/07 - 
/   vdjegara    01/29/07 - Creation
/

Sample Results
--------------
Our results below were obtained on a 2 CPU system with EMC clarion storage array with a sustained throughput of 
up to 150Mb/sec. 

If you are running on low end (for example on a single disk machine like laptop or desktop systems) or on the 
other hand on a very high end system results may be different, and we would like get your feedback if you notice 
any regression on such systems

               Basic | Secure | Speed |      Basic | Secure  | Speed |
LobSize        Write(Mb/sec)  | Ratio |      Read(Mb/sec)    | Ratio |
-----------------------------------------------------------------
 102400000       48.27 | 72.76 | 1.51 |        36.29 | 119.91 | 3.30 |
  10240000       49.08 | 69.73 | 1.42 |        35.30 | 98.71 | 2.80 |
   1024000       45.52 | 82.91 | 1.82 |        23.34 | 48.95 | 2.10 |
    102400       29.36 | 47.45 | 1.62 |         7.21 | 20.40 | 2.83 |
     10240        8.24 |  7.26 | 0.88 |         2.27 |  3.48 | 1.53 |


Setup 
-----
1. edit pre_setup.sql to put your tablespace datafile device name
   run it as "/as sysdba"

2. run - setup.sh (check setup.log for errors)

3. run - run_demo.sh (for 1 user test)
   - In each lobsize test, about 1Gb of data is loaded
   - Please be aware that this program allocates upto Lobsize memory (using malloc call) on the client side as read/write buffer
   - At the end of the run, a perl report generation script genrep.pl is called, which assumes perl binary is in
    /usr/bin directory, for different location, please modify it

4. run - run_xuser.sh (for 1 or more concurrent user tests)
   - Here again, only 1Gb of data is loaded (among all users) (for high number of users, you may need to edit iter parameter)

5. For run_xuser.sh reuse test, you have to edit init.ora and reduce undo_retention=10 (or less than 15), because
   in our test, we sleep for 15 seconds to deleted Lob segements to expire. Please note do this only for this 
   testing purpose and put it back to your original value after testing




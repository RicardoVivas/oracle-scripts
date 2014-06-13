#!/usr/bin/perl -w
# 
# $Header: genrep.pl 29-jan-2007.12:54:21 vdjegara Exp $
#
# genrep.pl
# 
# Copyright (c) 2007, Oracle. All rights reserved.  
#
#    NAME
#      genrep.pl - <one-line expansion of the name>
#
#    DESCRIPTION
#      <short description of component this file declares/defines>
#
#    NOTES
#      <other useful comments, qualifications, etc.>
#
#    MODIFIED   (MM/DD/YY)
#    vdjegara    01/29/07 - Perl script to generate report
#    vdjegara    01/29/07 - Creation


$num_args = $#ARGV + 1;

if ( $num_args != 1 ) {
  print "Usage: genrep.pl NumUsers (same as run_xuser.sh number user) \n";
  print "e.g. run_xuser.sh 4 ,  then genrep.pl 4 \n";
  print " \n";
  exit;
}

$num_users=$ARGV[0];

$plsql_lob_api=0;
$plsql_data_api=0;
$oci_lob_api=0;
$oci_data_api=0;

@filename = split("\n", `ls -rt basicfile_*.log`);
$total = scalar(@filename);

for ($i=0; $i < $total; $i++)
{
#  print "$filename[$i]\n";
  open INFILE, "$filename[$i]" or die "couldn't open: $!" ;

  while (<INFILE>) {
       if ( /^Inserted LobSize=(\d.*) bytes.*$/ ) {
	 push(@BInsLobSize, $1);
       }
       if ( /^Avg Write Rate.* : (\d*.\d*) .*$/ ) {
	 push(@BWriteRate, $1);
       }
       if ( /^Avg Read Rate.* : (\d*.\d*) .*$/ ) {
         push(@BReadRate, $1);
       }
       if ( /DBMS_LOB/ ) {
	 $plsql_lob_api=1;
       }
       if ( /PLSQL Data/ ) {
         $plsql_data_api=1;
       }
       if ( /OCILob/ ) {
         $oci_lob_api=1;
       }
       if ( /OCI Data/ ) {
         $oci_data_api=1;
       }

  }
}

@filename = split("\n", `ls -rt  securefile_*.log`);
$total = scalar(@filename);

for ($i=0; $i < $total; $i++)
{
#  print "$filename[$i]\n";
  open INFILE, "$filename[$i]" or die "couldn't open: $!" ;

   while (<INFILE>) {
        if ( /^Inserted LobSize=(\d.*) bytes.*$/ ) {
          push(@SInsLobSize, $1);
	}
        if ( /^Avg Write Rate.* : (\d*.\d*) .*$/ ) {
          push(@SWriteRate, $1);
	}
        if ( /^Avg Read Rate.* : (\d*.\d*) .*$/ ) {
          push(@SReadRate, $1);
	}
   }
}	  

print "          \n";
print "          \n";

if ( $plsql_lob_api == 1 ) {
  print "  	        PLSQL - LOB API         	\n";
} 
elsif ( $plsql_data_api == 1 ) {
  print "      		PLSQL - DATA API             \n";
} 
elsif ( $oci_lob_api == 1 ) {
  print "          	OCI - LOB API                \n";
} 
elsif ( $oci_data_api == 1 ) {
  print "          	OCI - DATA API               \n";
}
else {
  print "          	API used is unknown 		\n";
} 
print "               Basic | Secure | Speed |      Basic | Secure  | Speed |\n";
print "LobSize        Write(Mb/sec)  | Ratio |      Read(Mb/sec)    | Ratio |\n";
print "---------------------------------------------------------------------- \n";
$iter=$#SInsLobSize;

$SWriteTotal = 0;
$BWriteTotal = 0;
$SReadTotal = 0;
$BReadTotal = 0;

for ($i=0 ; $i <= $iter ; $i++ ) {
 if ( $BInsLobSize[$i] = $SInsLobSize[$i] ) {

   $WSpeedRatio = $SWriteRate[$i]/$BWriteRate[$i];
   $RSpeedRatio = $SReadRate[$i]/$BReadRate[$i];

 if ( $num_users > 1 ) {
 #  To sum multiuser results 
   if ($i == 0 ) {
     $SWriteTotal= $SWriteTotal + $SWriteRate[$i];
     $BWriteTotal= $BWriteTotal + $BWriteRate[$i];   
     $WSpeedRatioTotal = $SWriteTotal/$BWriteTotal;  

     $SReadTotal= $SReadTotal + $SReadRate[$i];
     $BReadTotal= $BReadTotal + $BReadRate[$i];
     $RSpeedRatioTotal = $SReadTotal/$BReadTotal ;
   }
   else { 
     if ( $i % $num_users == 0) {	
       print "---------------------------------------------------------------------- \n";
       printf "%10d       %5.2f | %5.2f | %2.2f |        %5.2f | %5.2f | %2.2f | <-- Total \n",
       $BInsLobSize[$i-1], 
       $BWriteTotal, $SWriteTotal, $WSpeedRatioTotal,
       $BReadTotal, $SReadTotal , $RSpeedRatioTotal;
       print "---------------------------------------------------------------------- \n";
       $SWriteTotal = 0;
       $BWriteTotal = 0;
       $SReadTotal = 0;
       $BReadTotal = 0;

       $SWriteTotal= $SWriteTotal + $SWriteRate[$i];
       $BWriteTotal= $BWriteTotal + $BWriteRate[$i];
       $WSpeedRatioTotal = $SWriteTotal/$BWriteTotal;

       $SReadTotal= $SReadTotal + $SReadRate[$i];
       $BReadTotal= $BReadTotal + $BReadRate[$i];
       $RSpeedRatioTotal = $SReadTotal/$BReadTotal ;
 
     }
     else {
       $SWriteTotal= $SWriteTotal + $SWriteRate[$i];
       $BWriteTotal= $BWriteTotal + $BWriteRate[$i];
       $WSpeedRatioTotal = $SWriteTotal/$BWriteTotal;

       $SReadTotal= $SReadTotal + $SReadRate[$i];
       $BReadTotal= $BReadTotal + $BReadRate[$i];
       $RSpeedRatioTotal = $SReadTotal/$BReadTotal ;
     }
   }
 }
   printf "%10d       %5.2f | %5.2f | %2.2f |        %5.2f | %5.2f | %2.2f | \n", 
	$BInsLobSize[$i], 
	$BWriteRate[$i], $SWriteRate[$i], $WSpeedRatio,  
	$BReadRate[$i], $SReadRate[$i] , $RSpeedRatio ;

# to account for last lobsize file in multiuser test 
  if ( $num_users > 1 ) {
    if ( $i == $iter ) {
      print "---------------------------------------------------------------------- \n";
      printf "%10d       %5.2f | %5.2f | %2.2f |        %5.2f | %5.2f | %2.2f | <-- Total \n",
      $BInsLobSize[$i-1],
      $BWriteTotal, $SWriteTotal, $WSpeedRatioTotal,
      $BReadTotal, $SReadTotal , $RSpeedRatioTotal;
      print "---------------------------------------------------------------------- \n";
     }
   }
 }
 else {
   print "Basicfile lobsize and Securefile lobsize doesn't match"
 }
 
}

print "          \n";

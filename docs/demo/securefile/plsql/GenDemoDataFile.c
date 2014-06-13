/* Copyright (c) 2007, Oracle. All rights reserved.  */

/*

   NAME
     GenDemoDataFile.c - Lob demo data generator for pl/sql tests 

   DESCRIPTION

   EXPORT FUNCTION(S)

   INTERNAL FUNCTION(S)

   STATIC FUNCTION(S)

   NOTES

   MODIFIED   (MM/DD/YY)
   vdjegara    01/29/07 - Demo data generator
   vdjegara    01/29/07 - Creation

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>

/* proto type */
int main (int argc, char *argv[]);


int main(int argc, char *argv[]) 
{
  FILE *fp;
  int Iter=0;
  int LobSize;
  const int WriteBufSize=1048576;            /* Write 1Mb at a time */
  char *MaxBuffer;   
  char FileName[30];
  char command[30];

  int i;
 
  if (argc < 3 )
  {
    fprintf(stderr, "Usage: %s FileName LobSize \n", *argv);
    exit(1);
  }

  strcpy(FileName, argv[1]);
  LobSize = atoi(argv[2]);;               
    
  MaxBuffer = (char *)malloc(WriteBufSize * sizeof(char));
  if (MaxBuffer == NULL ) {
    printf ("Failed to allocate memory for LobSize = % d bytes \n", LobSize ); 
  }
  memset(MaxBuffer, 90, WriteBufSize);

  if (LobSize > WriteBufSize ) {
   Iter=(LobSize/WriteBufSize) + 1 ;
  }

  sprintf(command,"rm -f %s", FileName); 
  system (command);

  fp = fopen( FileName, "ab") ;
  if ( fp == NULL ) {
     printf ("File %s couldn't be created ..\n, FileName");
  }

  for (i=0; i <= Iter; i++) {
   fwrite (MaxBuffer , 1, WriteBufSize , fp);
  }

  printf ("File %s is created for dbms_lob.loadfromfile demo program of size > %d \n", FileName, LobSize);

  fclose (fp);
  return(0);

}


/* end of file GenDemoDataFile.c */


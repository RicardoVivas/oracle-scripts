load data
infile crer.csv
append into table crer
fields terminated by ',' optionally enclosed by '"'
trailing nullcols
(
author char,
title  char(2000),
pub    char,
year   char,
datecomments char,
class  char,
keywords char(4000),
sers   char,
isbn   char,
jrnl   char(1000),
volu   char(1000),
part   char(1000),
page   char(1000),
abst   char(1000),
id     SEQUENCE(MAX,1)
)

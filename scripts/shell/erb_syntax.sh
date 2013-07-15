#! /bin/sh

#if [ "$#" -ne 1  ]; then
#echo ""
#echo " ERROR : Invalid number of arguments. Provide template file name"
#exit 
#fi

export PATH=/bin:$PATH
for foo in `find $HOME/code/puppet/modules -name "*.erb"`; do
 erb -P -x -T '-' $foo | ruby -c | grep "OK" > /dev/null || echo "Syntax error in $foo"
done

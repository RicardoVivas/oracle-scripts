--
-- Run one script on all the databases. Might run more than once on one database, since there are
-- different tns names pointing to same database
--
--

if [ "$#" -ne 2  ]; then
echo ""
echo " ERROR : Invalid number of arguments. Provide sys password and SQL script name. The SQL script need to end with exit command"
exit 
fi

for i in `cat ~/code/puppet/modules/oracle/files/init/tnsnames.ora | grep -v '^[[:space:]]'  | grep -v '^$' | grep -v '^#' | awk -F '=' '{print $1}'`; do
echo ""
echo "------------------- Connect to database $i ----------------------------------------"
sqlplus sys/$1@$i as sysdba $2
done
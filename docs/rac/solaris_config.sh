
mkdir /export/home/oracle
mkdir /export/home/grid
chown oracle:oinstall /export/home/oracle
chown oracle:grid /export/home/grid



groupadd -g 1000 oinstall
groupadd -g 1020 asmadmin
groupadd -g 1021 asmdba
groupadd -g 1022 asmoper
groupadd -g 1031 dba
groupadd -g 1032 oper
useradd -u 1100 -g oinstall -G asmoper,asmadmin,asmdba -s /bin/bash -d /home/grid grid
useradd -u 1101 -g oinstall -G oper,dba,asmdba -s /bin/bash -d /home/oracle oracle

mkdir /export/home/oracle
mkdir /export/home/grid
chown oracle:oinstall /export/home/oracle
chown oracle:grid /export/home/grid


#Since slice 0 was used you need to make those available to ASM by setting the permissions and ownership as show below.
chown grid:asmadmin /dev/rdsk/c0t2d0*
chown grid:asmadmin /dev/rdsk/c0t3d0*
chown grid:asmadmin /dev/rdsk/c0t4d0*

chmod 660 /dev/rdsk/c0t2d0*
chmod 660 /dev/rdsk/c0t3d0*
chmod 660 /dev/rdsk/c0t4d0*



mkdir -p /u01/app/11.2.0/grid
mkdir -p /u01/app/grid
chown -R grid:oinstall /u01
mkdir -p /u01/app/oracle
chown oracle:oinstall /u01/app/oracle
chmod -R 775 /u01
mkdir -p /u01/app/11.2.0/grid
chown grid:oinstall /u01/app/11.2.0/grid
chmod -R 775 /u01/app/11.2.0/grid
mkdir -p /u01/app/oracle/product/11.2.0/db_1
chown -R oracle:oinstall /u01/app/oracle
chmod -R 775 /u01/app/oracle



##Create two projects for Oracle GI and Oracle RDBMS users respectively. Set the share memory parameters.
projadd -U grid -K "project.max-shm-memory=(priv,6g,deny)" user.grid
projmod -sK "project.max-sem-nsems=(priv,512,deny)" user.grid
projmod -sK "project.max-sem-ids=(priv,128,deny)" user.grid
projmod -sK "project.max-shm-ids=(priv,128,deny)" user.grid
projmod -sK "project.max-shm-memory=(priv,6g,deny)" user.grid


projadd -U oracle -K "project.max-shm-memory=(priv,6g,deny)" user.oracle
projmod -sK "project.max-sem-nsems=(priv,512,deny)" user.oracle
projmod -sK "project.max-sem-ids=(priv,128,deny)" user.oracle
projmod -sK "project.max-shm-ids=(priv,128,deny)" user.oracle
projmod -sK "project.max-shm-memory=(priv,6g,deny)" user.oracle

/usr/sbin/projmod -sK "process.max-file-descriptor=(priv,65536,deny)" user.oracle
/usr/sbin/projmod -sK "process.max-file-descriptor=(priv,65536,deny)" user.grid

#If the max file descriptors are not set properly there will be errors starting OUI. You see it later on.

#Set the TCP and UDP kernel parameters

/usr/sbin/ndd -set /dev/tcp tcp_smallest_anon_port 9000
/usr/sbin/ndd -set /dev/tcp tcp_largest_anon_port 65500
/usr/sbin/ndd -set /dev/udp udp_smallest_anon_port 9000
/usr/sbin/ndd -set /dev/udp udp_largest_anon_port 65500


allow root login in sshd_config
set /etc/ssh/sshd_config file LoginGraceTime 0. and restart ssh

## Enable Core file creation
coreadm
mkdir -p /var/cores
coreadm -g /var/cores/%f.%n.%p.%t.core -e global -e global-setid -e log -d process -d proc-setid
coreadm

## disble ntp
/usr/sbin/svcadm disable ntp
/usr/sbin/svcadm restart ssh



#run devfsadm to let solaris recognizes the disk if not attached before solaris installation
#pkginfo -i SUNWarc SUNWbtool SUNWhea SUNWlibC SUNWlibm SUNWlibms SUNWsprot SUNWtoo SUNWi1of SUNWi1cs SUNWi15cs SUNWxwfnt SUNWcsl

#ifconfig  e1000g1  192.168.2.21  netmask 255.255.255.0 up
#ifconfig  e1000g2  10.10.10.21  netmask 255.255.255.0 up
#ifconfig  e1000g3  192.168.56.51  netmask 255.255.255.0 up

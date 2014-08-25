#!/bin/bash

ROOTFILE="/root/.ssh/authorized_keys"
USERFILE="/home/stratio/.ssh/"
USER="stratio"

if [ -s  $ROOTFILE ] ; then
	echo "clave publica de root en su sitio"
else
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAujkdR4yDCIpWFelWdSwx9QbuPMxKKYbNvPK1BcKq/Ic0S8hvD7Ryk9bILMMcFxFXNMVURgQZ5DFLJouq8klOENUf4j3davsLc6FZ8oIeGdD5sxSR8UouuE7x4QNbbOV5sym1xlL8ZtdmZK5JPnmfv+QWkvn06gm2G2Q6l47PT/am9wQdoqG68j9gqT4JXbxnWBfmCaDbbz2CwUPD9vyUToQfi4ar5tCZIenX5hUAd/dEYO7RMMUrocL8LvXY7lIYF/GG0YzNZ4edqF6CXy7DjFH70BOFwLqEUuvfLyaUzDlXQAOZMY6Su7El1FORLkjHZL9zre6i98Y7H8wB09dD2w==" >> $ROOTFILE

chmod -R 400 /root/.ssh/authorized_keys
fi

apt-get install -y ncftp logwatch snmp snmpd ntp ntpdate apticron vim lshw htop iptraf iftop strace fail2ban zip unzip gzip bzip2 rar unrar arj ncompress zoo cpio lzop sysstat

if id -u $USER >/dev/null 2>&1; then
	echo "user exists"
else
	adduser --disabled-password --gid 100 --gecos "" stratio
	mkdir /home/stratio/.ssh/
	cp -p -r /root/.ssh/authorized_keys /home/stratio/.ssh/ 
	chmod -R 400 /home/stratio/.ssh/authorized_keys
	chown -R stratio:100 /home/stratio/.ssh
fi

rm -rf /var/tmp ;ln -s /tmp/ /var/tmp

sed -i "9s/true/false/g" /etc/default/sysstat ;/etc/init.d/sysstat restart

cp -p -r  /etc/ssh/sshd_config  /etc/ssh/sshd_config.`date +%d%m%Y`

if cat /etc/ssh/sshd_config| grep "AllowUsers stratio" >/dev/null 2>&1; then
	echo "usuario permitido"
else
	echo "AllowUsers stratio" >> /etc/ssh/sshd_config
fi

if cat /etc/ssh/sshd_config| grep "UseDNS no" >/dev/null 2>&1; then
		echo "DNS already disabled"
	else
		echo "UseDNS no" >> /etc/ssh/sshd_config
fi

sed -i 's/#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/g'  /etc/ssh/sshd_config
sed -i 's/PermitRootLogin yes/#PermitRootLogin no/g'  /etc/ssh/sshd_config
sed -i 's/#AuthorizedKeysFile/AuthorizedKeysFile/g'  /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g'  /etc/ssh/sshd_config

/etc/init.d/ssh restart

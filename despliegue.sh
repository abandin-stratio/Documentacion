#!/bin/bash

#log_begin_msg() { :; }
#log_action_begin_msg() { :; }
#log_action_end_msg() { :; }

. /lib/lsb/init-functions


ROOTFILE="/root/.ssh/authorized_keys"
USERFILE="/home/stratio/.ssh/"
USER="stratio"
FILESCRIPT="/home/$USER/$(basename $0)"
DOMAINNAME="stratio.com"
DNSFILE="/etc/resolv.conf"
IP_ADDR=$(ip addr| egrep inet" "| grep -v 127| cut -d" " -f6 | cut -d/ -f1)
HOSTNAME=$(hostname)

if dnsdomainname > /dev/null 2&>1; then
        log_action_msg "dominio fqdn correcto"
        else
        sed -i '/'$HOSTNAME'/d' /etc/hosts
        echo $IP_ADDR $HOSTNAME.$DOMAINNAME $HOSTNAME >> /etc/hosts
fi


log_begin_msg "Adding public keys"

if [ -s  $ROOTFILE ] ; then
	log_action_begin_msg "root public key already exists. rewriting..."
	rm -rf $ROOTFILE &&
	echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAujkdR4yDCIpWFelWdSwx9QbuPMxKKYbNvPK1BcKq/Ic0S8hvD7Ryk9bILMMcFxFXNMVURgQZ5DFLJouq8klOENUf4j3davsLc6FZ8oIeGdD5sxSR8UouuE7x4QNbbOV5sym1xlL8ZtdmZK5JPnmfv+QWkvn06gm2G2Q6l47PT/am9wQdoqG68j9gqT4JXbxnWBfmCaDbbz2CwUPD9vyUToQfi4ar5tCZIenX5hUAd/dEYO7RMMUrocL8LvXY7lIYF/GG0YzNZ4edqF6CXy7DjFH70BOFwLqEUuvfLyaUzDlXQAOZMY6Su7El1FORLkjHZL9zre6i98Y7H8wB09dD2w==" >> $ROOTFILE &&

	if [ ! -d /root/.ssh/ ]; then
		mkdir -p /root/.ssh/
	else

			log_action_msg "Folder containing root already exists"

	fi

else
	echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAujkdR4yDCIpWFelWdSwx9QbuPMxKKYbNvPK1BcKq/Ic0S8hvD7Ryk9bILMMcFxFXNMVURgQZ5DFLJouq8klOENUf4j3davsLc6FZ8oIeGdD5sxSR8UouuE7x4QNbbOV5sym1xlL8ZtdmZK5JPnmfv+QWkvn06gm2G2Q6l47PT/am9wQdoqG68j9gqT4JXbxnWBfmCaDbbz2CwUPD9vyUToQfi4ar5tCZIenX5hUAd/dEYO7RMMUrocL8LvXY7lIYF/GG0YzNZ4edqF6CXy7DjFH70BOFwLqEUuvfLyaUzDlXQAOZMY6Su7El1FORLkjHZL9zre6i98Y7H8wB09dD2w==" >> $ROOTFILE

	chmod -R 400 /root/.ssh/authorized_keys
fi
	log_action_msg "Done"
#	log_action_end_msg $?

if  cat $DNSFILE | grep nameserver >/dev/null 2>&1; then
	echo "dns configurados"
else
	echo "nameserver 8.8.8.8" >> $DNSFILE
fi

	log_action_begin_msg "Installing basic packages"

	apt-get update &&
	apt-get install -y ncftp exim4 logwatch snmp snmpd ntp ntpdate vim lshw htop iptraf iftop strace fail2ban zip unzip gzip bzip2 rar unrar arj ncompress zoo cpio lzop sysstat || exit

	log_action_msg "Done"
	log_action_end_msg $?

	log_begin_msg "Checking $USER user"

if id -u $USER >/dev/null 2>&1; then
	
		if [ -s /etc/sudoers ]; then
			
			if cat /etc/sudoers | grep NOPASSWD 2>&1; then
				echo "usuario stratio en fichero sudoers"
			else
				echo "stratio ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
			fi

		else
			apt-get update && apt-get install -y sudo
			echo "stratio ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
			visudo -c > /dev/null 2>&1
		fi

	if [ ! -d /home/$USER/.ssh ]; then
		mkdir -p /home/$USER/.ssh
	else

		log_action_msg "certificate folder of " $USER " exists"

	fi

	cp -p -r /root/.ssh/authorized_keys /home/stratio/.ssh/
	chmod -R 400 /home/stratio/.ssh/authorized_keys
	chown -R stratio:100 /home/stratio/.ssh

	log_action_msg "User already exists"

else
	adduser --disabled-password --gid 100 --gecos "" stratio
	mkdir /home/stratio/.ssh/
	cp -p -r /root/.ssh/authorized_keys /home/stratio/.ssh/
	chmod -R 400 /home/stratio/.ssh/authorized_keys
	chown -R stratio:100 /home/stratio/.ssh
fi

	log_action_msg "Done"
	log_action_end_msg $?

if [  -d /var/tmp ] ; then
	rm -rf /var/tmp 
	ln -s /tmp/ /var/tmp
	else
		exit 0
fi


sed -i "9s/true/false/g" /etc/default/sysstat ;/etc/init.d/sysstat restart

log_begin_msg "Changing ssh configuration"

if [ ! -f /etc/ssh/sshd_config.`date +%d%m%Y` ]; then
	cp -p -r  /etc/ssh/sshd_config  /etc/ssh/sshd_config.`date +%d%m%Y`
else

	log_action_begin_msg "A current copy of sshd_config already exists"

fi

if cat /etc/ssh/sshd_config| grep "AllowUsers stratio" >/dev/null 2>&1; then

	log_action_msg "User already allowed"

else

	echo "AllowUsers root" >> /etc/ssh/sshd_config

fi

if cat /etc/ssh/sshd_config| egrep "UseDNS no" >/dev/null 2>&1; then
		log_action_msg "DNS already disabled"
	else
		echo "UseDNS no" >> /etc/ssh/sshd_config
fi

sed -i 's/#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/g'  /etc/ssh/sshd_config
#sed -i 's/PermitRootLogin yes/PermitRootLogin no/g'  /etc/ssh/sshd_config
sed -i 's/#AuthorizedKeysFile/AuthorizedKeysFile/g'  /etc/ssh/sshd_config
#sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g'  /etc/ssh/sshd_config



service ssh restart > /dev/null 2>&1 && log_begin_msg "Restarting ssh"

rm -rf $FILESCRIPT 

log_action_end_msg $?

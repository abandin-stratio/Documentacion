#!/bin/bash

. /lib/lsb/init-functions

INSTALL_HOME="/home/stratio"
ZABBIX_SERVER_CONF="/etc/"
ZABBIX_AGENT_CONF="/etc/"
USER="stratio"
FILESCRIPT="/home/$USER/$(basename $0)"
TYPE=$1


if [ $# -ne 1 ]; then
	echo $TYPE
	echo $
#	status=1
	log_action_msg "Wrong paramenter number"
	log_action_end_msg $status
	exit 1
fi


#Añadimos los repos a las maquinas

log_begin_msg "Checking zabbix repos"

if dpkg -l| grep zabbix-release | grep ii >/dev/null 2>&1; then

log_action_msg "Zabbix repos in place"

#instalamos los repos
else
	log_action_msg "Checking if repo file installation is local"
	if [ ! -f $INSTALL_HOME/zabbix-release_2.2-1+trusty_all.deb ]; then
		log_action_cont_msg "Downloading"
	wget -P $INSTALL_HOME http://repo.zabbix.com/zabbix/2.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_2.2-1+trusty_all.deb
	dpkg -i $INSTALL_HOME/zabbix-release_2.2-1+trusty_all.deb  >/dev/null 2>&1
	apt-get update  >/dev/null 2>&1
		log_action_end_msg $?
	else
	log_action_msg "Installing repo"
	dpkg -i $INSTALL_HOME/zabbix-release_2.2-1+trusty_all.deb
	apt-get update
	fi
fi

if [ "$TYPE" = "server" ]; then

#Instalacion del servidor
log_action_msg "Installing Zabbix Server"
apt-get -y install zabbix-server-mysql zabbix-frontend-php
log_action_end_msg $?

else

	if [ "$TYPE" = "agent" ]; then
	#Instalacion del Agente
	log_action_msg "Installing  Zabbix Agent"
	 apt-get update  >/dev/null 2>&1 && apt-get install zabbix-agent
	log_action_end_msg $?
	else log_action_cont_msg "I think you misspelled the option"
		exit 1
	fi

fi

rm -rf $FILESCRIPT

log_begin_msg "Everything is fine"
log_action_end_msg $?
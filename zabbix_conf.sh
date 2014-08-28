#!/bin/bash

ZABBIX_CONF_FILE="/etc/zabbix/zabbix_agentd.conf"
ZABBIX_SERVER=$1
SOURCEIP=$(hostname --ip-address |awk {'print $1'})
HOSTNAME=$(hostname --fqdn)
FILESCRIPT="/home/$USER/$(basename $0)"

if [ $# -ne 1 ]; then
	echo $TYPE
	echo $
#	status=1
	log_action_msg "Wrong paramenter number"
	log_action_msg "You have to declare Zabbix Server Name"
	log_action_end_msg $status
	exit 1
fi


if [ -s $ZABBIX_CONF_FILE ]; then

#SourceIP=148.251.151.3
sed -i 's/^.\bSourceIP\b.*$/SourceIP='$SOURCEIP'/' $ZABBIX_CONF_FILE

#EnableRemoteCommands=1
sed -i 's/^.\bEnableRemoteCommands\b.*$/EnableRemoteCommands=1/' $ZABBIX_CONF_FILE

#LogRemoteCommands=1
sed -i 's/^.\bLogRemoteCommands\b.*$/LogRemoteCommands=1/' $ZABBIX_CONF_FILE

#Server=admin-preproduccion-benchmark.stratio.com
sed -i 's/^\bServer\b.*$/Server='$ZABBIX_SERVER'/' $ZABBIX_CONF_FILE

#ListenPort=10050
sed -i 's/^*\b#ListenPort\b.*$/ListenPort=10050/' $ZABBIX_CONF_FILE

#ListenIP=0.0.0.0
sed -i 's/^\bListenIP\b.*$/ListenIP=0.0.0.0/' $ZABBIX_CONF_FILE

#StartAgents=3
sed -i 's/^\bStartAgents\b.*$/StartAgents=3/' $ZABBIX_CONF_FILE

#ServerActive=admin-preproduccion-benchmark.stratio.com
sed -i 's/^\bServerActive\b.*$/ServerActive='$ZABBIX_SERVER'/' $ZABBIX_CONF_FILE

#Hostname=admin-preproduccion-benchmark.stratio.com
sed -i 's/^\bHostname\b.*$/Hostname='$HOSTNAME'/' $ZABBIX_CONF_FILE
else
	echo "Zabbix configuration file does not exists"
fi

/etc/init.d/zabbix-agent restart

rm -rf $FILESCRIPT

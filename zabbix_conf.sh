!/bin/bash

ZABBIX_CONF_FILE="/etc/zabbix/zabbix_agentd.conf"
SOURCEIP=$(hostname --ip-address |awk {'print $1'})
HOSTNAME=$(hostname --fqdn)

#SourceIP=148.251.151.3
sed 's/^.\bSourceIP\b.*$/SourceIP='$SOURCEIP'/' $ZABBIX_CONF_FILE


#EnableRemoteCommands=1
sed 's/^.\bEnableRemoteCommands\b.*$/EnableRemoteCommands=1/' $ZABBIX_CONF_FILE

#LogRemoteCommands=1
sed 's/^.\bLogRemoteCommands\b.*$/LogRemoteCommands=1/' $ZABBIX_CONF_FILE

#Server=admin-preproduccion-benchmark.stratio.com
sed 's/^\bServer\b.*$/Server='$HOSTNAME'/' $ZABBIX_CONF_FILE

#ListenPort=10050
sed 's/^.\bEnableRemoteCommands\b.*$/EnableRemoteCommands=1/' $ZABBIX_CONF_FILE

#ListenIP=0.0.0.0
sed 's/^.\bEnableRemoteCommands\b.*$/EnableRemoteCommands=1/' $ZABBIX_CONF_FILE

#StartAgents=3
sed 's/^.\bEnableRemoteCommands\b.*$/EnableRemoteCommands=1/' $ZABBIX_CONF_FILE

#ServerActive=admin-preproduccion-benchmark.stratio.com
sed 's/^.\bEnableRemoteCommands\b.*$/EnableRemoteCommands=1/' $ZABBIX_CONF_FILE

#Hostname=admin-preproduccion-benchmark.stratio.com
sed 's/^.\bEnableRemoteCommands\b.*$/EnableRemoteCommands=1/' $ZABBIX_CONF_FILE




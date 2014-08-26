#!/bin/sh

# Script de configuración de servidores en Hetzner
# v1.0

RUTA="/root" # Ruta en la que busca los paquetes a instalar

# Para acceso con contraseña
STRATIOPASS=contraseñadificil # Contraseña del usuario 'stratio'
ROOTPASS=contraseñamasdificilaun # Contraseña del usuario 'root'
# Para acceso por clave publica/privada, nombre de los ficheros de certificado
STRATIOCERT=certificadostratio
ROOTCERT=certificadoroot
ENFORCECERT=false # Si está a 'true' entonces se deshabilita el acceso por contraseña (pero se permite el acceso como 'root'). Si está a 'false' se deshabilita el acceso como 'root' pero se admiten ambos metodos de autenticacion

# Buscará los siguientes binarios en $RUTA y si existen los instala
JAVA6=jdk-6u45-linux-x64-rpm.bin
JAVA7=jdk-7u60-linux-x64.tar.gz
# Directorios que pondra en el 'alternatives'
JAVA6DIR=/usr/java/jdk1.6.0_45
JAVA7DIR=/usr/java/jdk1.7.0_60

ENABLEEPELREPO=true # Habilitar EPEL
ENABLEFORGEREPO=true # Habilitar rpmforge
ADDITIONALPKGS="man mlocate sysstat iftop iotop lsof zip unzip tcpdump kernel-headers gcc make strace" # Paquetes adicionales a instalar

## NO CAMBIAR NADA A PARTIR DE AQUÍ
###################################

# Cambiamos contraseñas
useradd -m stratio
chpasswd <<EOF
root:$ROOTPASS
stratio:$STRATIOPASS
EOF
echo "Contraseñas cambiadas"

# Cambiamos de zona horaria
if [ -f /usr/share/zoneinfo/Europe/Madrid ]; then
	sed s:Europe/[a-z]*":Europe/Madrid":gI /etc/sysconfig/clock >/tmp/clock
	mv -f /tmp/clock /etc/sysconfig/clock
	rm -f /etc/localtime
	ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
fi

# Cambiamos el "locale"
if [ -f /usr/share/i18n/locales/es_ES ]; then
	sed s:\".*\.UTF-8:\"es_ES\.UTF-8:gI /etc/sysconfig/i18n >/tmp/i18n
	mv -f /tmp/i18n /etc/sysconfig/i18n
fi

# Cambiamos el teclado
sed s/\"de\"/\"es\"/g /etc/sysconfig/keyboard >/tmp/keyboard
mv -f /tmp/keyboard /etc/sysconfig/keyboard

echo "Locale cambiado"

# Securizamos el SSH. Añadir todos los patrones que haga falta
test -f /tmp/sshd_config && rm -f /tmp/sshd_config
if [ -f $RUTA/$STRATIOCERT ]; then
	if [ ! -d /home/stratio/.ssh ]; then
		mkdir /home/stratio/.ssh
		chmod 700 /home/stratio/.ssh
	fi
	cat $RUTA/$STRATIOCERT >> /home/stratio/.ssh/authorized_keys
	chmod 700 /home/stratio/.ssh/authorized_keys
	chown -R stratio:stratio /home/stratio/.ssh
fi
if [ -f $RUTA/$ROOTCERT ]; then
	if [ ! -d /root/.ssh ]; then
		mkdir /root/.ssh
		chmod 700 /root/.ssh
	fi
	cat $RUTA/$ROOTCERT >> /root/.ssh/authorized_keys
	chmod 700 /root/.ssh/authorized_keys
fi
if [ $ENFORCECERT = "true" ]; then
	sed s/"PasswordAuthentication yes"/"PasswordAuthentication no"/g /etc/ssh/sshd_config >/tmp/sshd_config
	mv -f /tmp/sshd_config /etc/ssh/sshd_config
else
	sed s/"PermitRootLogin yes"/"PermitRootLogin no"/g /etc/ssh/sshd_config >/tmp/sshd_config
	mv -f /tmp/sshd_config /etc/ssh/sshd_config
fi
echo "SSH configurado"
echo "Recuerda reiniciar el servicio ssh (service sshd restart)"

# Configuramos el firewall. Unicamente permitimos SSH y desde Paradigma.
if [ ! -f /etc/sysconfig/iptables ]; then
	cat >/etc/sysconfig/iptables <<EOF
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT

# SSH
-A INPUT -m state --state NEW -m tcp -p tcp -s 62.82.24.134 --dport 22 -j ACCEPT

-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
EOF
fi
echo "Firewall configurado"

# Deshabilitamos IPv6 en la interfaz eth0
sed s/IPV6INIT=yes/IPV6INIT=no/g /etc/sysconfig/network-scripts/ifcfg-eth0 >/tmp/ifcfg-eth0
mv -f /tmp/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0
echo "IPv6 deshabilitado"

# Agregamos repositorios: EPEL y RepoForge. Deshabilitar si no es necesario
[ $ENABLEEPELREPO = "true" ] && `rpm -Uvh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm`
[ $ENABLEFORGEREPO = "true" ] && `rpm -Uvh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm`

# Actualizamos e instalamos paquetes adicionales. Añadir/quitar los requeridos.
yum -y update
yum -y install $ADDITIONALPKGS
echo "Paquetes instalados"

# Instalamos Java si está disponible
if [ -f $RUTA/$JAVA6 ]; then
	if [ ! -x $RUTA/$JAVA6 ]; then
		chmod 750 $RUTA/$JAVA6
	fi
	cd /tmp
	$RUTA/$JAVA6
	rm -f *.rpm
	cd -
fi
if [ -f $RUTA/$JAVA7 ]; then
	if [ ! -d /usr/java ]; then
		mkdir /usr/java
	fi
	cp $RUTA/$JAVA7 /usr/java
	cd /usr/java
	tar -xzf $JAVA7
	rm -f $JAVA7
	chown -R root:root jdk1.7.*
	rm -f latest
	rm -f default
	if [ -d $JAVA6DIR ]; then
		ln -s $JAVA6DIR default
	else
		ln -s $JAVA7DIR default
	fi
	ln -s $JAVA7DIR latest
	cd -
fi
if [ -d /usr/java ]; then
	alternatives --install /usr/bin/java java /usr/java/default/bin/java 1000
	alternatives --install /usr/bin/java java /usr/java/latest/bin/java 900
fi
echo "JAVA instalado"

# Habilitamos servicios
chkconfig iptables on
chkconfig ntpd on
echo "Servicios habilitados"

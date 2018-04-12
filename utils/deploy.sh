#!/bin/bash
#set -x
myname=$(cat /etc/hostname)
if [ $(grep -c /etc/locale.gen ) -ne 2 ]
then
cat  > /etc/locale.gen << EOF
en_US.UTF-8 UTF-8
it_IT.UTF-8 UTF-8
EOF
locale-gen
fi

if [ $myname == 'chiodino' ] || [ $myname == 'finferlo' ]
then

echo set up slapd
cat > /tmp/slapd-selections << EOF
slapd   slapd/password2 password pippopippo
slapd   slapd/password1 password pippopippo
slapd   shared/organization     string	$myname.bosco.local
slapd   slapd/domain    string	$myname.bosco.local
EOF

/usr/bin/debconf-set-selections /tmp/slapd-selections

apt-get -y install slapd ldap-utils

memberof=$(ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:/// -b cn=config dn |grep -c memberof)
if [ $memberof -eq 0 ]
then ldapadd -Q -Y EXTERNAL -H ldapi:/// -f /viagrant-share/ldap/module_memberof.ldif ;fi

refint=$(ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:/// -b cn=config dn |grep -c refint)
if [ $refint -eq 0 ]
then
	ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f /viagrant-share/ldap/module_refint_load.ldif
	ldapadd -Q -Y EXTERNAL -H ldapi:/// -f  /viagrant-share/ldap/module_refint_set.ldif
fi

userexist=$(ldapsearch -x -D cn=admin,dc=$myname,dc=bosco,dc=local -w pippopippo -b dc=$myname,dc=bosco,dc=local 'uid=collidinguser' dn|grep -c "^dn: ")
if [ $userexist -eq 0 ]
then
ldappass=$(slappasswd -h {SHA} -s "${myname}pass")
sed -e "s/HOSTNAME/$myname/g;
	s|PASSWORD|$ldappass|" \
	/viagrant-share/ldap/test_tree.ldif > /viagrant-share/ldap/test_tree.ldif.$myname
ldapadd  -x -D cn=admin,dc=$myname,dc=bosco,dc=local -w pippopippo -f /viagrant-share/ldap/test_tree.ldif.$myname
rm /viagrant-share/ldap_tree.ldif.$myname
fi
fi

if [ $myname == 'chiodino' ]
then
apt-get -y install mariadb-server
userexist=$(mysql mysql -NBe "select count(user) from user where user='icinga';")
if [ $userexist -eq 0 ]
then
mysql -e "CREATE USER 'icinga'@'%' IDENTIFIED BY 'icingapass';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'icinga'@'%' WITH GRANT OPTION;"
fi
sed -i 's/^bind-address/#bind-address/' \
	/etc/mysql/mariadb.conf.d/50-server.cnf

test -d /var/lib/mysql/icinga2/ || \
	mysql -e "create database icinga2;"

test -f /var/lib/mysql/icingaweb2/icinga_acknowledgements.frm || \
	mysql icinga2 < /viagrant-share/icinga2-ido-mysql-schema.sql

test -d /var/lib/mysql/icingaweb2/ || \
	mysql -e "create database icingaweb2;"
test -f /var/lib/mysql/icingaweb2/icingaweb_user.frm || \
	mysql icingaweb2 < /viagrant-share/mysql_icingaweb.sql
mysql_pass=$(openssl passwd -1 mysqlpass)
mysql icingaweb2 -e "INSERT IGNORE INTO icingaweb_group VALUES (1,'mysqlgroup',NULL,NOW(),NULL);"
mysql icingaweb2 -e "INSERT IGNORE INTO icingaweb_user VALUES ('mysqluser',1,'$mysql_pass',NOW(),NULL);"
mysql icingaweb2 -e "INSERT IGNORE INTO icingaweb_group_membership VALUES (1,'mysqluser',NOW(),NULL);"
systemctl restart mariadb
fi

if [ $myname == 'boletus' ]
then
test -f /etc/apt/sources.list.d/icinga2.list || \
	echo 'deb http://packages.icinga.com/debian icinga-stretch main' > /etc/apt/sources.list.d/icinga2.list
test -f /var/lib/apt/lists/packages.icinga.com_debian_dists_icinga-stretch_InRelease || apt-get update

if [ $( apt-key  list 2> /dev/null |grep -c icinga) -lt 1 ]
then
wget -O - https://packages.icinga.com/icinga.key | apt-key add - 
apt-get update
fi

DEBIAN_FRONTEND=noninteractive apt-get -yq install   icinga2 icinga2-ido-mysql
	#apt-get -y -q install icinga2 icinga2-ido-mysql

test -f /var/lib/icinga2/certs//boletus.bosco.local.crt || \
	icinga2 node setup --master --cn boletus.bosco.local

test -f /etc/icinga2/features-enabled/compatlog.conf || \
	icinga2 feature enable compatlog

test -f /etc/icinga2/features-enabled/ido-mysql.conf || \
	icinga2 feature enable ido-mysql

grep -q 'host = "localhost"' /etc/icinga2/features-available/ido-mysql.conf && \
	sed -i 's/host =.*/host = "chiodino.bosco.local"/;
		s/user =.*/user = "icinga"/;
		s/password =.*/password = "icingapass"/;' \
		/etc/icinga2/features-available/ido-mysql.conf

test -f /etc/icinga2/conf.d/api_user.conf || \
	printf "object ApiUser 	\"director\"  {\n  password = \"pippopippopippo\"\n  permissions = [ \"*\", ]\n}\n" \
	>/etc/icinga2/conf.d/api_user.conf
test -f /etc/icinga2/conf.d/icinga-test-objects.conf|| \
	cp /viagrant-share/icinga-test-objects.conf /etc/icinga2/conf.d/icinga-test-objects.conf

/etc/init.d/icinga2 restart

pwd
fi
if [ $myname == 'porcino' ]
then
	apt-get -y install apache2 php php-intl php-imagick php-gd php-ldap \
		php7.0-mysql php7.0-pgsql php-mysql php-curl php-mbstring
	apt-get install -y git curl
	addgroup --system icingaweb2
	usermod -a -G icingaweb2 www-data

	test -d /var/log/icingaweb2 || install -d -o www-data -g icingaweb2 -m 777 -d /var/log/icingaweb2

	test -d /root/icingaweb2/icingaweb2 && rm -rf /root/icingaweb2/icingaweb2
	test -d /usr/share/icingaweb2 && rm -rf /usr/share/icingaweb2
	
	#first clone
	git clone https://github.com/Icinga/icingaweb2.git /root/icingaweb2/icingaweb2

	sed -i 's|^;date.timezone.*|date.timezone="Europe/Rome"|' \
		/etc/php/7.0/apache2/php.ini

	a2enmod rewrite
	service apache2 restart
fi

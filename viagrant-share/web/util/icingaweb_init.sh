#!/bin/bash
testset=$1

for conf in authentication.ini config.ini groups.ini resources.ini roles.ini
do
	cp /viagrant-share/web/icingaweb2-conf/$conf  \
		/etc/icingaweb2/$conf
	if [ "X${testset}" != "X" ]
	then
		conf_add=/viagrant-share/web/tests/$testset/conf/$conf
		test -f $conf_add && \
			cat $conf_add >> /etc/icingaweb2/$conf
	fi
done
for conf in backends.ini commandtransports.ini config.ini security.ini
do
	cp /viagrant-share/web/monitor-conf/$conf \
		/etc/icingaweb2/modules/monitoring
done
chown -R root:icingaweb2 /etc/icingaweb2/
/usr/share/icingaweb2/bin/icingacli module enable monitoring


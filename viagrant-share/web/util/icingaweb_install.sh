#!/bin/bash
gitversion=$1
if [ "X${gitversion}" == "X" ]
then gitversion=master; fi

        if [ ! -d /root/icingaweb2/icingaweb2 ]
	then echo git repo clone missing; exit 123; fi
        test -d /etc/icingaweb2 && rm -rf /etc/icingaweb2
        mkdir -p /etc/icingaweb2/modules/monitoring

        test -d /usr/share/icingaweb2 && rm -rf /usr/share/icingaweb2

        #first install
	cd /root/icingaweb2/icingaweb2 
	#git checkout --quiet $gitversion  -b test-$gitversion > /dev/null
	git checkout --quiet $gitversion > /dev/null
        rsync --delete --exclude=.git --chown www-data:icingaweb2 -a /root/icingaweb2/icingaweb2/ /usr/share/icingaweb2/
        /usr/share/icingaweb2/bin/icingacli setup config webserver apache \
                --document-root /usr/share/icingaweb2/public/ > /etc/apache2/sites-enabled/icingaweb2.conf
#        /usr/share/icingaweb2/bin/icingacli setup config directory
#        /usr/share/icingaweb2/bin/icingacli setup token create
#        /usr/share/icingaweb2/bin/icingacli setup token show

        for conf in authentication.ini config.ini groups.ini resources.ini roles.ini
        do
                cp /viagrant-share/web/icingaweb2-conf/$conf  \
                        /etc/icingaweb2/$conf
        done
        for conf in backends.ini commandtransports.ini config.ini security.ini
        do
                cp /viagrant-share/web/monitor-conf/$conf \
                        /etc/icingaweb2/modules/monitoring
        done
        chown -R root:icingaweb2 /etc/icingaweb2/

        /usr/share/icingaweb2/bin/icingacli module enable monitoring
        service apache2 restart


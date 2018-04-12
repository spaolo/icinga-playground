#!/bin/bash
userprefix=$1
usertype=$2

if [ "X$usertype" == "X" ]
then usertype=user; fi

if [ $(grep -c "login-failed" /tmp/icingaweb_hosts.txt) -gt 0 ]
       then echo "KO $userprefix login failed" ; exit; fi

if [ $(grep -c . /tmp/icingaweb_hosts.txt) -lt 1 ]
       then echo "KO $userprefix No visible hosts" ; exit; fi
if [ $usertype == user ]
then
if [ $(grep -c . /tmp/icingaweb_hosts.txt) -gt 1 ]
       then echo "KO $userprefix Too many visible hosts ".$(cat /tmp/icingaweb_hosts.txt |tr "\n" " "); exit; fi

if [ $(grep -c -F -x "${userprefix}-visible" /tmp/icingaweb_hosts.txt) -eq 1 ]
      then
                echo "OK $userprefix As expected "$(cat /tmp/icingaweb_hosts.txt);
       else
                echo "KO $userprefix Unexpected "$(cat /tmp/icingaweb_hosts.txt);
       fi
else
if [ $(grep -c . /tmp/icingaweb_hosts.txt) -ne 3 ]
then 
	echo "KO $userprefix unexpected visible hosts "$(cat /tmp/icingaweb_hosts.txt |tr "\n" " ");
	exit;
else
	echo "OK $userprefix As expected "$(cat /tmp/icingaweb_hosts.txt |tr "\n" " ");
	exit;
fi
fi

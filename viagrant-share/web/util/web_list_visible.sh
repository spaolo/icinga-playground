#!/bin/bash
username=$1
password=$2

curl -Ss\
	-c /tmp/test_cookie.txt \
	http://porcino.bosco.local/icingaweb2/authentication/login > /dev/null
curl -Ss\
	-c /tmp/test_cookie.txt \
	-b /tmp/test_cookie.txt \
	'http://porcino.bosco.local/icingaweb2/authentication/login?_checkCookie=1' > /dev/null

curl -Ss\
	-e http://porcino.bosco.local/icingaweb2/authentication/login \
	-b /tmp/test_cookie.txt -c /tmp/test_cookie.txt \
	http://porcino.bosco.local/icingaweb2/authentication/login > /tmp/curl_page.txt

grep '^<input type="hidden"' /tmp/curl_page.txt \
	|sed 's/.*name="//;s/" value="/=/;s/".*//' \
	|sed 's/|/%7C/' \
	> /tmp/login_data.txt
echo "btn_submit=Login" >> /tmp/login_data.txt
echo "username=$username" >> /tmp/login_data.txt
printf "password=$password" >> /tmp/login_data.txt

	#-X POST 
curl  -Ss \
	-b /tmp/test_cookie.txt -c /tmp/test_cookie.txt \
	-d "$(cat /tmp/login_data.txt|tr '\n' '&')" \
	--dump-header /tmp/curl_header.txt \
	http://porcino.bosco.local/icingaweb2/authentication/login \
	> /dev/null

if [ $(grep -c "Location: /icingaweb2/dashboard" /tmp/curl_header.txt) -lt 1 ]
	then echo "login-failed" > /tmp/icingaweb_hosts.txt; exit; fi

curl -Ss \
	-b /tmp/test_cookie.txt -c /tmp/test_cookie.txt \
	http://porcino.bosco.local/icingaweb2/monitoring/list/hosts \
	> /tmp/curl_page.txt

grep 'icingaweb2/monitoring/host/show?' /tmp/curl_page.txt \
	|sed 's|</a>.*||;
	s/<[^>]*>//g;s/ *//g' \
	> /tmp/icingaweb_hosts.txt
cat /tmp/icingaweb_hosts.txt

curl -Ss \
	--dump-header /tmp/curl_header.txt \
	-b /tmp/test_cookie.txt -c /tmp/test_cookie.txt \
	http://porcino.bosco.local/icingaweb2/authentication/logout \
	> /tmp/curl_page.txt

#if [ $(grep -c . /tmp/icingaweb_hosts.txt) -gt 1 ]
#	then echo "KO Too many visible hosts ".$(cat /tmp/icingaweb_hosts.txt |tr "\n" " "); exit; fi
#
#if [ $(grep -c . /tmp/icingaweb_hosts.txt) -lt 1 ]
#	then echo "KO No visible hosts" ; exit; fi
#
#if [ $(grep -c -F -x "${username}-visible" /tmp/icingaweb_hosts.txt) -eq 1 ]
#	then
#		 echo "OK As expected "$(cat /tmp/icingaweb_hosts.txt);
#	else
#		 echo "KO Unexpected "$(cat /tmp/icingaweb_hosts.txt);
#	fi


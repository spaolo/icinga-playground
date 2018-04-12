#!/bin/bash
testnum=$1
verlabel=$2
script_dir=/viagrant-share/web/util
test_dir=/viagrant-share/web/tests

if [ "X$testnum" == "X" ]
then echo KO test condition required ; exit 127;fi
if [ "X$verlabel" == "X" ]
then echo KO version label required ; exit 127;fi

cat  $test_dir/$testnum/condition_desc

printf "" > /var/log/icingaweb2/icingaweb2.log
chown www-data:icingaweb2 /var/log/icingaweb2/icingaweb2.log

$script_dir/icingaweb_init.sh $testnum

bash $test_dir/$testnum/inner_test.sh

mv /var/log/icingaweb2/icingaweb2.log $test_dir/out/icingaweb2.log.$verlabel.$testnum

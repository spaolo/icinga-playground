#!/bin/bash
commit=$1
if [ "X$commit" == "X" ]
then commit='master'; fi

test_dir=/viagrant-share/web/tests
script_dir=/viagrant-share/web/util

$script_dir/icingaweb_install.sh $commit
for cond_desc in $test_dir/*/condition_desc
do
a=$(dirname $cond_desc)
condition=$(basename $a)

$test_dir/run_condition.sh $condition $commit\
	| sed -e "s/^/ver $commit $condition /"

done

#!/bin/bash

test_dir=/viagrant-share/web/tests
test -d $test_dir/out || \
	mkdir -p  $test_dir/out

exec 2>&1
exec &> >(tee $test_dir/out/test_results)

echo "testing 2.5.0"
$test_dir/test_single_version.sh ebe1917

echo "testing 2.5.1"
$test_dir/test_single_version.sh 6f5d0a1

echo "testing PR #3250"
$test_dir/test_single_version.sh 5cb7ded

echo "testing pre PR #3250 parent"
$test_dir/test_single_version.sh 02391e6

echo "testing PR #3403"
$test_dir/test_single_version.sh 4c9733c


#!/bim/bash
script_dir=/viagrant-share/web/util

$script_dir/web_list_visible.sh mysqluser mysqlpass > /dev/null
$script_dir/check_list.sh mysqluser user

$script_dir/web_list_visible.sh collidinguser chiodinopass > /dev/null
$script_dir/check_list.sh ldapuser user  

$script_dir/web_list_visible.sh collidinguser@admin finferlopass > /dev/null
$script_dir/check_list.sh ldapuser admin 

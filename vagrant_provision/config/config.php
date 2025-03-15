<?php
// Config file for Vagrant VM

// $*_binary is the full path & file where a license manager binary is located.
// They must have execute permissions for the web server user.
// FlexLM (lmutil) and Mathematica (monitorlm) are currently supported.
$lmutil_binary="/opt/lmtools/lmutil";
$monitorlm_binary="/opt/lmtools/monitorlm";

// $cache_dir specifies what directory is used to store/process cache files.
// /tmp is not advised.  $cache_lifetime is how long a cache file is retained
// in seconds. e.g. 7200 = 2 hours.
$cache_dir="/var/cache/phplw/";
$cache_lifetime=7200;

// License expiration alerts are sent to $notify_address.
// $do_not_reply_address is filled in the reply field.
// License alert emails are disabled when either is left blank.
// Licenses expiring within $lead_time (in days) are included in the alerts.
$smtp_host="";
$smtp_login="";
$smtp_password="";
$smtp_tls="";
$smtp_port="";
$notify_address="";
$do_not_reply_address="";
$lead_time=30;
$smtp_debug=false;

// $disable_autorefresh, when set to 1, will halt automatic refresh of certain
// page views.  Make sure $collection_interval matches, in minutes, the cron
// schedule for license_util.php.
$disable_autorefresh=0;
$collection_interval=10;

// Database information.  Note that only the mysqli driver is suppoprted.
$db_hostname="localhost";
$db_username="vagrant";
$db_password="vagrant";
$db_database="vagrant";

// IMPORTANT: Change this to 0 when used in production!
// Allows debug logging when set to 1.
$debug=1;
?>

## Overview
The phpLicenseWatcher software is designed to monitor and manage software license servers efficiently. It provides a comprehensive overview of the health of one or more license servers, ensuring that administrators can easily check which licenses are being used and identify the current users.
To help administrators analyze trends, the software offers charts of historical license usage, providing valuable insights into license utilization over time. This helps organizations reduce software licensing costs through better management and timely renewals.

## Key features

* Shows the health of one or more license servers
* Checks which licenses are being used and displays who is currently using them
* Gets a list of licenses, their expiration date and the number of days to expiration
* E-mails alerts of licenses that will expire within certain time period ie. within next 10 days.
* Provides charts of historical license usage

> [!IMPORTANT]  
> We are soliciting feedback on what features or improvements would be of interest to users of this software.  We are particularily curious of any installation, or initial use challenges you may have faced as a primary goal is to make initial install as simple as possible.
> Please contact us via our new [gitter.im chat room](https://app.gitter.im/#/room/#phpLicenseWatcher:gitter.im) or you can email us at 

## Limitations

   Currently FlexLM and MathLM (Mathematica) servers are supported.  If you are interested in support for additional vendors please open a new issue.  Software vendor must provide a linux command line tool, or API that allows querying current license usage.

## Requirements

* Web server capable of running PHP
* MySQL compatible database
* FlexLM lmutil binary for the OS you are running the web server on.

## Installation process
1. Retrieve required packages for your OS/distribution.  Any Linux distribution should work however we develop against Ubuntu.
   * Apache2
   * PHP 8 or higher (7.3 and up probably still work, but are not recommended)
   * [https://getcomposer.org](Composer) for PHP package management
   * MySQL-server, MySQL-client, PHP MySQL Extension
   * You need the Linux Standard Base (LSB) to run Linux-precompiled FlexLM binaries.

   For example, using Ubuntu 20.04:
   ```
   sudo apt install apache2 php mysql-server mysql-client php-mysql lsb composer
   ```
2. Clone repository locally using git
   ```
   git clone https://github.com/rpi-dotcio/phpLicenseWatcher.git /var/www/html/
   ```
3. Install the monitoring binaries for the vendors you wish to monitor.  Recommended location is /opt/lmtools/ . These should have come from the vendor with the software you are looking to monitor.  The FlexLM lmtuil from any of the vendors will work with others.

```
   mkdir /opt/lmtools/

   #copy the FlexLM (lmutil) and/or Mathematica (monitorlm) Linux binary files to this folder.
  
   #Make sure they have the execute permission set
   chmod +x /opt/lmtools/*
```

5. Create the database
   ```
   mysqladmin create licenses
   mysql -f licenses < phplicensewatcher.sql
   ```
6. Edit "config.php" for the proper values for your setup, typically just the database username, and password.  Brief instructions are provided within the file as code comments.

7. Setup cron to run scheduled tasks
   ```
   0,10,20,30,40,50 * * * * php /var/www/html/license_util.php >> /dev/null
   15 0 * * 1  php /var/www/html/license_cache.php >> /dev/null
   0 6 * * 1 php /var/www/html/license_alert.php >> /dev/null
   ```
8. You should use your web server's built in capabilities to password protect your site.  See some example configurations in our [https://github.com/phpLicenseWatcher/phpLicenseWatcher/wiki/Example-Apache-Configurations](example apache configurations wiki page).
9. Install PHP packages using composer.
```
cd /var/html/www/
composer install
```
9. Navigate to page `check_installation.php` under the admin table to check for possible installation issues.

### What is "LM Default Usage Reporting"?
FlexLM documentation states that FlexLM should report license usage based on licenses checked out by users, only.
However, our internal FlexLM systems were also including reserved (but not in use) licenses in that count.

* When set `true`, PHP License Watcher will accept FlexLM's usage report as is.  This is the original behavior for PHP License Watcher (up to build 220503).
* When set `false`, PHP License Watcher will do its own count of licenses in use, based on identified users of the license, and record/report that value.
* This value is set on a per server basis.  It is found through server administration.
* For Mathematica, this value is set `true` and should not be changed.

### Crontab details

There are CLI scripts that need to be executed on a regular basis ie. license_util.php and license_cache.php.

* License_util.php is used to get current license usage. It should be run periodically throughout the day every 10 minutes.
* License_cache.php stores the total number of available licenses on particular day. This script is necessary because you may have temporary keys that may expire on a particular day and you want to capture that. It should be run once a day preferably soon after the midnight after which license server should invalidate all the expired keys.
* license_alert.php checks for expiring licenses and emails admins.  We run once a week.


## Example Screenshots
![Alt text](https://github.com/rpi-dotcio/phpLicenseWatcher/raw/assets/screenshot1.png?raw=true "List of license servers")
![Alt text](https://github.com/rpi-dotcio/phpLicenseWatcher/raw/assets/screenshot2.png?raw=true "List of features and licenses in use")
![Alt text](https://github.com/rpi-dotcio/phpLicenseWatcher/raw/assets/screenshot3.png?raw=true "License usage statistics")
![Alt text](https://github.com/rpi-dotcio/phpLicenseWatcher/raw/assets/screenshot4.png?raw=true "License usage statistics")


## Warning

   There is no warranty on this package.  We wrote this system to help keep tabs on our FlexLM servers.  We are not FlexLM developers and base this system on using the publicly available commands such as lmstat, lmdiag.
   This may not work for you.  No specific platform is targeted, but development and testing is primarily done with Ubuntu Server 20.04 LTS.

   Please do not run phplicensewatcher on a publicly available Internet server because it has not been audited to make sure it is secure.  It likely isn't. You have been warned.

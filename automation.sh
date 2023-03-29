#!/bin/bash

sudo apt update -y

apache2_installed=$(dpkg -s apache2 | grep Status | awk '{print $NF}')
if [ "$apache2_installed" != "installed" ]
then
        sudo apt install apache2 -y
fi

apache2_status=$(systemctl is-active apache2)
if [ "$apache2_status" != "active" ]
then
        sudo systemctl restart apache2
fi

apache2_enabled=$(systemctl is-enabled apache2)
if [ "$apache2_enabled" != "enabled" ]
then
        sudo systemctl enable apache2
fi

if [ ! -f /var/www/html/inventory.html ]
then
    echo -e "Log Type\tTime Created\tType\tSize" > /var/www/html/inventory.html
fi

cd /var/log/apache2/
timestamp=$(date '+%d%m%Y-%H%M%S')
myname="smruti"
s3_bucket="upgrad-smruti"
tar -cvf /tmp/${myname}-httpd-logs-${timestamp}.tar *.log
aws s3 cp /tmp/${myname}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

tar_file_size=$(du -h /tmp/${myname}-httpd-logs-${timestamp}.tar | awk '{print $1 }')

echo -e "httpd-logs\t$timestamp\ttar\t$tar_file_size" >> /var/www/html/inventory.html

if [ ! -f /etc/cron.d/automation ]
then
        echo "0 0 * * * root /root/Automation_Project/automation.sh" > /etc/cron.d/automation
fi

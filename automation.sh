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

cd /var/log/apache2/
timestamp=$(date '+%d%m%Y-%H%M%S')
myname="smruti"
s3_bucket="upgrad-smruti"

tar -cvf /tmp/${myname}-httpd-logs-${timestamp}.tar *.log
aws s3 cp /tmp/${myname}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

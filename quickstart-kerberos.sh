#!/usr/bin/env bash
sudo service mysqld start
sudo service krb5kdc start
sudo service kadmin start
sudo service cloudera-scm-agent start
sudo service cloudera-scm-server start
echo 'Waiting for Cloudera Manager API...'
/home/cloudera/cm_api.py live-echo > /dev/null
curl -XPOST -u 'cloudera:cloudera' -H 'Content-Type: application/json' 'http://localhost:7180/api/v12/clusters/Cloudera%20QuickStart/commands/start'
/bin/bash
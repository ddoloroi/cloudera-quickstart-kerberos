#!/usr/bin/env bash
chown -R cloudera-scm: /var/log/cloudera-scm-server/
chown -R cloudera-scm: /usr/share/cmf/python/Lib/
sudo service mysqld start
sudo service krb5kdc start
sudo service kadmin start
sudo service cloudera-scm-agent start
sudo service cloudera-scm-server start

echo 'Waiting for Cloudera Manager API...'
/home/cloudera/cm_api_old.py live-echo > /dev/null

echo "Configuring Kerberos"
python /home/cloudera/configure-kerberos.py

echo "Starting Cloudera services"
python /home/cloudera/start-services.py

echo "Starting Kafka"
sudo /etc/init.d/kafka start
/usr/share/kafka-manager/bin/kafka-manager -Dhttp.port=9099 -DZK_HOSTS=localhost:2181 > /var/log/kafka-manager/kafka-manager.log &

/bin/bash
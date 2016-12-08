#!/usr/bin/env bash
echo "Installing Kerberos"
/home/cloudera/kerberos
/etc/init.d/mysqld start
/etc/init.d/cloudera-quickstart-init

echo "Configuring CM Cluster"
/home/cloudera/cloudera-manager --express

echo "Disabling Clock offset check..."
curl -XPOST -u 'cloudera:cloudera' -H 'Content-Type: application/json' -d '{"items":[{"method":"PUT","url":"/api/v8/cm/allHosts/config?message=Updated%20all%20hosts%20configurations.","body":{"items":[{"name":"host_clock_offset_thresholds","value":"{\"warning\":\"never\",\"critical\":\"never\"}"}]},"contentType":"application/json"}]}' 'http://localhost:7180/api/v6/batch'

echo "Disabling Free diskspace check..."
curl -XPOST -u 'cloudera:cloudera' -H 'Content-Type: application/json' -d '{"items":[{"method":"PUT","url":"/api/v8/clusters/Cloudera%20QuickStart/services/hdfs/roleConfigGroups/hdfs-DATANODE-BASE/config?message=Updated%20configurations.","body":{"items":[{"name":"datanode_free_space_thresholds","value":"{\"warning\":\"never\",\"critical\":\"never\"}"}]},"contentType":"application/json"}]}' 'http://localhost:7180/api/v6/batch'

echo "Disabling Swapping checks..."
curl -XPOST -u 'cloudera:cloudera' -H 'Content-Type: application/json' -d '{"items":[{"method":"PUT","url":"/api/v8/cm/allHosts/config?message=Updated%20configurations.","body":{"items":[{"name":"host_memswap_thresholds","value":"{\"warning\":\"never\",\"critical\":\"never\"}"}]},"contentType":"application/json"}]}' 'http://localhost:7180/api/v6/batch'
curl -XPOST -u 'cloudera:cloudera' -H 'Content-Type: application/json' -d '{"items":[{"method":"PUT","url":"/api/v8/clusters/Cloudera%20QuickStart/services/yarn/roleConfigGroups/yarn-RESOURCEMANAGER-BASE/config?message=Updated%20configurations.","body":{"items":[{"name":"process_swap_memory_thresholds","value":"{\"warning\":\"never\",\"critical\":\"never\"}"}]},"contentType":"application/json"}]}' 'http://localhost:7180/api/v6/batch'
curl -XPOST -u 'cloudera:cloudera' -H 'Content-Type: application/json' -d '{"items":[{"method":"PUT","url":"/api/v8/clusters/Cloudera%20QuickStart/services/hdfs/roleConfigGroups/hdfs-NAMENODE-BASE/config?message=Updated%20configurations.","body":{"items":[{"name":"process_swap_memory_thresholds","value":"{\"warning\":\"never\",\"critical\":\"never\"}"}]},"contentType":"application/json"}]}' 'http://localhost:7180/api/v6/batch'

echo "Disabling Yarn RM Health check..."
curl -XPOST -u 'cloudera:cloudera' -H 'Content-Type: application/json' -d '{"items":[{"method":"PUT","url":"/api/v8/clusters/Cloudera%20QuickStart/services/yarn/config?message=Updated%20configurations.","body":{"items":[{"name":"yarn_resourcemanagers_health_enabled","value":"false"}]},"contentType":"application/json"}]}' 'http://localhost:7180/api/v6/batch'
curl -XPOST -u 'cloudera:cloudera' -H 'Content-Type: application/json' -d '{"items":[{"method":"PUT","url":"/api/v8/clusters/Cloudera%20QuickStart/services/yarn/roleConfigGroups/yarn-NODEMANAGER-BASE/config?message=Updated%20configurations.","body":{"items":[{"name":"nodemanager_health_checker_health_enabled","value":"false"}]},"contentType":"application/json"}]}' 'http://localhost:7180/api/v6/batch'

echo "Installing dependencies"
yum install -y python-pip wget rpm-build spectool java-1.8.0-openjdk-devel
cd /tmp

echo "Installing OpenTSDB"
wget https://github.com/OpenTSDB/opentsdb/releases/download/v2.3.0RC2/opentsdb-2.3.0_RC2.rpm
rpm -i opentsdb-2.3.0_RC2.rpm --nodeps

echo "Installing Kafka"
wget http://apache.40b.nl/kafka/0.10.0.1/kafka_2.11-0.10.0.1.tgz
cd /opt
tar -zxvf /tmp/kafka_2.11-0.10.0.1.tgz
ln -s kafka_2.11-0.10.0.1/ kafka

echo "Installing Kafka manager"
wget ftp://195.220.108.108/linux/sourceforge/s/sc/schedulerbox/tmp/scala_dependencies/kafka-manager-1.3.1.6-1.noarch.rpm
rpm -i kafka-manager-1.3.1.6-1.noarch.rpm

pip install --upgrade cm-api
mv /home/cloudera/cm_api.py /home/cloudera/cm_api_old.py

echo "Configuring Kerberos"
python /home/cloudera/configure-kerberos.py

/etc/init.d/cloudera-scm-agent stop
/etc/init.d/cloudera-scm-server stop
/etc/init.d/mysqld stop
/etc/init.d/kadmin stop
/etc/init.d/krb5kdc stop

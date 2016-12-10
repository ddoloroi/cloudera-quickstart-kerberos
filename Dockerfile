FROM cloudera/quickstart
MAINTAINER cheelio@gmail.com

# Zookeeper
EXPOSE 2181:2181
# OpenTSDB
EXPOSE 4242:4242
# Cloudera Manager
EXPOSE 7180:7180
# Hadoop
EXPOSE 8088:8088
# Kafka
EXPOSE 9092:9092
# Kafka Manager
EXPOSE 9099:9099
# Spark History
EXPOSE 18088:18088
# Hadoop History
EXPOSE 19888:19888
# Impala
EXPOSE 50070:50070
# HBase Master
EXPOSE 60010:60010
# HBase Region
EXPOSE 60030:60030

ADD contents/configure-kerberos.py /home/cloudera
ADD contents/express-deployment.json /home/cloudera
ADD contents/kafka /etc/init.d
ADD contents/kerberos-config.json /home/cloudera
ADD contents/opentsdb-tables /etc/init.d
ADD contents/quickstart-kerberos.sh /home/cloudera
ADD contents/start-services.py /home/cloudera

RUN touch /var/lib/cloudera-quickstart/.cloudera-manager
RUN touch /var/tmp/cm_api.log
RUN chmod +rw /var/tmp/cm_api.log

RUN yum localinstall -y https://github.com/OpenTSDB/opentsdb/releases/download/v2.3.0RC2/opentsdb-2.3.0_RC2.rpm || true
RUN yum localinstall -y ftp://195.220.108.108/linux/sourceforge/s/sc/schedulerbox/tmp/scala_dependencies/kafka-manager-1.3.1.6-1.noarch.rpm || true
RUN yum install -y python-pip wget rpm-build spectool java-1.8.0-openjdk-devel mysql-connector-java || true

RUN wget http://apache.40b.nl/kafka/0.10.0.1/kafka_2.11-0.10.0.1.tgz -O /opt/kafka_2.11-0.10.0.1.tgz
RUN tar -zxvf /opt/kafka_2.11-0.10.0.1.tgz -C /opt
RUN ln -s /opt/kafka_2.11-0.10.0.1 /opt/kafka

ENV CMF_JDBC_DRIVER_JAR /usr/share/java/mysql-connector-java.jar
ENV CMF_JAVA_OPTS "-Xmx2048m -XX:PermSize=256m -XX:MaxPermSize=256m"

RUN /usr/bin/mysqld_safe --basedir=/usr --datadir=/var/lib/mysql \
    & sleep 5 \
    && /usr/sbin/cmf-server \
    & /home/cloudera/kerberos \
    && /home/cloudera/cm_api.py live-echo \
    && service cloudera-scm-agent start \
    && /home/cloudera/cm_api.py live-deployment < /home/cloudera/express-deployment.json \
    && /home/cloudera/cm_api.py --method POST "clusters/Cloudera Quickstart/commands/deployClientConfig" > /dev/null \
    && curl -XPOST -u 'cloudera:cloudera' -H 'Content-Type: application/json' -d '{"items":[{"method":"PUT","url":"/api/v8/cm/allHosts/config?message=Updated%20all%20hosts%20configurations.","body":{"items":[{"name":"host_clock_offset_thresholds","value":"{\"warning\":\"never\",\"critical\":\"never\"}"}]},"contentType":"application/json"}]}' 'http://localhost:7180/api/v6/batch' \
    && curl -XPOST -u 'cloudera:cloudera' -H 'Content-Type: application/json' -d '{"items":[{"method":"PUT","url":"/api/v8/clusters/Cloudera%20QuickStart/services/hdfs/roleConfigGroups/hdfs-DATANODE-BASE/config?message=Updated%20configurations.","body":{"items":[{"name":"datanode_free_space_thresholds","value":"{\"warning\":\"never\",\"critical\":\"never\"}"}]},"contentType":"application/json"}]}' 'http://localhost:7180/api/v6/batch' \
    && curl -XPOST -u 'cloudera:cloudera' -H 'Content-Type: application/json' -d '{"items":[{"method":"PUT","url":"/api/v8/cm/allHosts/config?message=Updated%20configurations.","body":{"items":[{"name":"host_memswap_thresholds","value":"{\"warning\":\"never\",\"critical\":\"never\"}"}]},"contentType":"application/json"}]}' 'http://localhost:7180/api/v6/batch' \
    && curl -XPOST -u 'cloudera:cloudera' -H 'Content-Type: application/json' -d '{"items":[{"method":"PUT","url":"/api/v8/clusters/Cloudera%20QuickStart/services/yarn/roleConfigGroups/yarn-RESOURCEMANAGER-BASE/config?message=Updated%20configurations.","body":{"items":[{"name":"process_swap_memory_thresholds","value":"{\"warning\":\"never\",\"critical\":\"never\"}"}]},"contentType":"application/json"}]}' 'http://localhost:7180/api/v6/batch' \
    && curl -XPOST -u 'cloudera:cloudera' -H 'Content-Type: application/json' -d '{"items":[{"method":"PUT","url":"/api/v8/clusters/Cloudera%20QuickStart/services/hdfs/roleConfigGroups/hdfs-NAMENODE-BASE/config?message=Updated%20configurations.","body":{"items":[{"name":"process_swap_memory_thresholds","value":"{\"warning\":\"never\",\"critical\":\"never\"}"}]},"contentType":"application/json"}]}' 'http://localhost:7180/api/v6/batch' \
    && curl -XPOST -u 'cloudera:cloudera' -H 'Content-Type: application/json' -d '{"items":[{"method":"PUT","url":"/api/v8/clusters/Cloudera%20QuickStart/services/yarn/config?message=Updated%20configurations.","body":{"items":[{"name":"yarn_resourcemanagers_health_enabled","value":"false"}]},"contentType":"application/json"}]}' 'http://localhost:7180/api/v6/batch' \
    && curl -XPOST -u 'cloudera:cloudera' -H 'Content-Type: application/json' -d '{"items":[{"method":"PUT","url":"/api/v8/clusters/Cloudera%20QuickStart/services/yarn/roleConfigGroups/yarn-NODEMANAGER-BASE/config?message=Updated%20configurations.","body":{"items":[{"name":"nodemanager_health_checker_health_enabled","value":"false"}]},"contentType":"application/json"}]}' 'http://localhost:7180/api/v6/batch' \
    && pip install --upgrade cm-api \
    && mv /home/cloudera/cm_api.py /home/cloudera/cm_api_old.py



ENTRYPOINT ["/home/cloudera/quickstart-kerberos.sh"]
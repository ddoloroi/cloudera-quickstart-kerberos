FROM cloudera/quickstart
MAINTAINER cheelio@gmail.com

ADD contents/configure-kerberos.py /home/cloudera
ADD contents/create-quickstart-kerberos.sh /home/cloudera
ADD contents/express-deployment.json /home/cloudera
ADD contents/kafka /etc/init.d
ADD contents/kerberos-config.json /home/cloudera
ADD contents/opentsdb-tables /etc/init.d
ADD contents/quickstart-kerberos.sh /home/cloudera
ADD contents/start-services.py /home/cloudera


RUN /home/cloudera/kerberos
RUN /etc/init.d/mysqld start
RUN /etc/init.d/cloudera-quickstart-init

RUN /home/cloudera/cloudera-manager --express

RUN curl -XPOST -u 'cloudera:cloudera' -H 'Content-Type: application/json' -d '{"items":[{"method":"PUT","url":"/api/v8/cm/allHosts/config?message=Updated%20all%20hosts%20configurations.","body":{"items":[{"name":"host_clock_offset_thresholds","value":"{\"warning\":\"never\",\"critical\":\"never\"}"}]},"contentType":"application/json"}]}' 'http://localhost:7180/api/v6/batch'
RUN curl -XPOST -u 'cloudera:cloudera' -H 'Content-Type: application/json' -d '{"items":[{"method":"PUT","url":"/api/v8/clusters/Cloudera%20QuickStart/services/hdfs/roleConfigGroups/hdfs-DATANODE-BASE/config?message=Updated%20configurations.","body":{"items":[{"name":"datanode_free_space_thresholds","value":"{\"warning\":\"never\",\"critical\":\"never\"}"}]},"contentType":"application/json"}]}' 'http://localhost:7180/api/v6/batch'
RUN curl -XPOST -u 'cloudera:cloudera' -H 'Content-Type: application/json' -d '{"items":[{"method":"PUT","url":"/api/v8/cm/allHosts/config?message=Updated%20configurations.","body":{"items":[{"name":"host_memswap_thresholds","value":"{\"warning\":\"never\",\"critical\":\"never\"}"}]},"contentType":"application/json"}]}' 'http://localhost:7180/api/v6/batch'
RUN curl -XPOST -u 'cloudera:cloudera' -H 'Content-Type: application/json' -d '{"items":[{"method":"PUT","url":"/api/v8/clusters/Cloudera%20QuickStart/services/yarn/roleConfigGroups/yarn-RESOURCEMANAGER-BASE/config?message=Updated%20configurations.","body":{"items":[{"name":"process_swap_memory_thresholds","value":"{\"warning\":\"never\",\"critical\":\"never\"}"}]},"contentType":"application/json"}]}' 'http://localhost:7180/api/v6/batch'
RUN curl -XPOST -u 'cloudera:cloudera' -H 'Content-Type: application/json' -d '{"items":[{"method":"PUT","url":"/api/v8/clusters/Cloudera%20QuickStart/services/hdfs/roleConfigGroups/hdfs-NAMENODE-BASE/config?message=Updated%20configurations.","body":{"items":[{"name":"process_swap_memory_thresholds","value":"{\"warning\":\"never\",\"critical\":\"never\"}"}]},"contentType":"application/json"}]}' 'http://localhost:7180/api/v6/batch'
RUN curl -XPOST -u 'cloudera:cloudera' -H 'Content-Type: application/json' -d '{"items":[{"method":"PUT","url":"/api/v8/clusters/Cloudera%20QuickStart/services/yarn/config?message=Updated%20configurations.","body":{"items":[{"name":"yarn_resourcemanagers_health_enabled","value":"false"}]},"contentType":"application/json"}]}' 'http://localhost:7180/api/v6/batch'
RUN curl -XPOST -u 'cloudera:cloudera' -H 'Content-Type: application/json' -d '{"items":[{"method":"PUT","url":"/api/v8/clusters/Cloudera%20QuickStart/services/yarn/roleConfigGroups/yarn-NODEMANAGER-BASE/config?message=Updated%20configurations.","body":{"items":[{"name":"nodemanager_health_checker_health_enabled","value":"false"}]},"contentType":"application/json"}]}' 'http://localhost:7180/api/v6/batch'
RUN yum install -y python-pip wget rpm-build spectool java-1.8.0-openjdk-devel
RUN cd /tmp
RUN wget https://github.com/OpenTSDB/opentsdb/releases/download/v2.3.0RC2/opentsdb-2.3.0_RC2.rpm
RUN rpm -i opentsdb-2.3.0_RC2.rpm --nodeps
RUN wget http://apache.40b.nl/kafka/0.10.0.1/kafka_2.11-0.10.0.1.tgz
RUN cd /opt
RUN tar -zxvf /tmp/kafka_2.11-0.10.0.1.tgz
RUN ln -s kafka_2.11-0.10.0.1/ kafka
RUN wget ftp://195.220.108.108/linux/sourceforge/s/sc/schedulerbox/tmp/scala_dependencies/kafka-manager-1.3.1.6-1.noarch.rpm
RUN rpm -i kafka-manager-1.3.1.6-1.noarch.rpm
RUN pip install --upgrade cm-api
RUN mv /home/cloudera/cm_api.py /home/cloudera/cm_api_old.py
RUN python /home/cloudera/configure-kerberos.py

RUN /etc/init.d/cloudera-scm-agent stop
RUN /etc/init.d/cloudera-scm-server stop
RUN /etc/init.d/mysqld stop
RUN /etc/init.d/kadmin stop
RUN /etc/init.d/krb5kdc stop


ENTRYPOINT ["/home/cloudera/quickstart-kerberos.sh"]
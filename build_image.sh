#!/bin/bash
docker rm -f $(docker ps -a -q)
docker run --name quickstart.cloudera -d --hostname=quickstart.cloudera --privileged=true -t -i \
-p 50070:50070 -p 7180:7180 -p 4242:4242 -p 60010:60010 -p 60030:60030 -p 8088:8088 -p 19888:19888 -p 18088:18088 -p 21000:21000 -p 8888:8888 -p 9099:9099 -p 2181:2181 -p 9092:9092 \
cloudera/quickstart /bin/bash

docker cp express-deployment.json quickstart.cloudera:/home/cloudera
docker cp create-quickstart-kerberos.sh quickstart.cloudera:/home/cloudera
docker cp quickstart-kerberos.sh quickstart.cloudera:/home/cloudera
docker cp configure-kerberos.py quickstart.cloudera:/home/cloudera
docker cp kerberos-config.json quickstart.cloudera:/home/cloudera
docker cp start-services.py quickstart.cloudera:/home/cloudera
docker cp kafka quickstart.cloudera:/etc/init.d

docker exec quickstart.cloudera /home/cloudera/create-quickstart-kerberos.sh
docker stop quickstart.cloudera
docker commit quickstart.cloudera cheelio/cloudera-quickstart-kerberos
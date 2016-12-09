#!/bin/bash
docker rm -f $(docker ps -a -q)
docker run --name quickstart.cloudera --hostname=quickstart.cloudera --privileged=true -t -i \
-p 50070:50070 -p 7180:7180 -p 4242:4242 -p 60010:60010 -p 60030:60030 -p 8088:8088 -p 19888:19888 -p 18088:18088 -p 21000:21000 -p 8888:8888 -p 9099:9099 -p 2181:2181 -p 9092:9092 \
cheelio/cloudera-quickstart-kerberos




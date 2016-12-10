#!/bin/bash
docker rm -f $(docker ps -a -q)
docker run --name quickstart.cloudera --hostname=quickstart.cloudera --privileged=true -t -i -P cheelio/cloudera-quickstart-kerberos




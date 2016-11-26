#!/bin/bash
docker rm -f $(docker ps -a -q)
docker run --name quickstart.cloudera -d --hostname=quickstart.cloudera --privileged=true -t -i -p 21000:21000 -p 8888:8888 -p 7180:7180 cloudera/quickstart /bin/bash
docker cp express-deployment.json quickstart.cloudera:/home/cloudera
docker cp create-quickstart-kerberos.sh quickstart.cloudera:/home/cloudera/create-quickstart-kerberos.sh
docker cp quickstart-kerberos.sh quickstart.cloudera:/home/cloudera/quickstart-kerberos.sh
docker exec quickstart.cloudera /home/cloudera/create-quickstart-kerberos.sh
docker stop quickstart.cloudera
docker commit quickstart.cloudera cheelio/cloudera-quickstart-kerberos
#!/usr/bin/env bash
/home/cloudera/kerberos
/etc/init.d/mysqld start
/etc/init.d/cloudera-quickstart-init
/home/cloudera/cloudera-manager --express

curl -XPOST -u 'cloudera:cloudera' -H 'Content-Type: application/json' -d '{"items":[{"method":"PUT","url":"/api/v8/cm/allHosts/config?message=Updated%20all%20hosts%20configurations.","body":{"items":[{"name":"host_clock_offset_thresholds","value":"{\"warning\":\"never\",\"critical\":\"never\"}"}]},"contentType":"application/json"}]}' 'http://localhost:7180/api/v6/batch'
curl -XPOST -u 'cloudera:cloudera' -H 'Content-Type: application/json' -d '{"items":[{"method":"PUT","url":"/api/v8/cm/config","body":{"items":[{"name":"kdc_host","value":"quickstart.cloudera"},{"name":"security_realm","value":"CLOUDERA"}]},"contentType":"application/json"}]}' 'http://localhost:7180/api/v6/batch'
curl -XPOST -u 'cloudera:cloudera' -H 'Content-Type: application/json' -d '{"items":[{"method":"PUT","url":"/api/v8/cm/config","body":{"items":[{"name":"krb_manage_krb5_conf","value":"true"}]},"contentType":"application/json"}]}' 'http://localhost:7180/api/v6/batch'
curl -XPOST -u 'cloudera:cloudera' -H 'Content-Type: application/json' 'http://localhost:7180/api/v12/cm/commands/importAdminCredentials?username=cloudera-scm/admin@CLOUDERA&password=cloudera'
curl -XPOST -u 'cloudera:cloudera' -H 'Content-Type: application/json' 'http://localhost:7180/api/v10/cm/commands/generateCredentials'
curl -XPOST -u 'cloudera:cloudera' -H 'Content-Type: application/json' -d '{}' 'http://localhost:7180/api/v12/clusters/Cloudera%20QuickStart/commands/configureForKerberos'

/etc/init.d/cloudera-scm-agent stop
/etc/init.d/cloudera-scm-server stop
/etc/init.d/mysqld stop
/etc/init.d/kadmin stop
/etc/init.d/krb5kdc stop

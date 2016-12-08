import os
import time
import json
from optparse import OptionParser
import ConfigParser
from cm_api.api_client import ApiResource
config = ConfigParser.ConfigParser()

def enable_kerberos():
    cluster_config_file = open("/home/cloudera/kerberos-config.json")
    cluster_configs = json.load(cluster_config_file)
    cluster_name = cluster_configs["cluster_name"]
    kdc_master = cluster_configs["kdc_master"]
    dr_kdc_master = cluster_configs["dr_kdc_master"]
    kdc_admin_user = cluster_configs["kdc_admin_user"]
    # domain = cluster_configs["network"]
    kdc_pass = cluster_configs["kdc_pass"]
    realm = cluster_configs["kb_realm"]
    wd = os.getcwd()

    cm_host = cluster_configs["cm_host"]
    api = ApiResource('localhost', version=12)
    cm = api.get_cloudera_manager()
    cm.update_config({'SECURITY_REALM': '%s' % realm, 'KDC_HOST': '%s' % kdc_master})
    cluster = api.get_cluster(cluster_name)

    #bring down the cluster and management service
    print "Stopping services..."
    cmd = cluster.stop()
    cmd.wait()
    cmd = cm.get_service().stop()
    cmd.wait()

    #import the credentials
    print "Importing Credentials.."
    cm.import_admin_credentials(kdc_admin_user, kdc_pass).wait()

    print "Updating service configs for kerberos.."
    hdfs = cluster.get_service("hdfs")
    #enable kerberos on hdfs
    hdfs.update_config({'hadoop_security_authorization': 'true', 'hadoop_security_authentication': 'kerberos'})

    #update datanode configurations
    hdfs.get_role_config_group('HDFS-DATANODE-BASE').update_config(
        {'dfs_datanode_port':"1004","dfs_datanode_http_port": "1006", "dfs_datanode_data_dir_perm": "700"})

    #enable kerberos on zookeeper
    cluster.get_service("zookeeper").update_config({'enableSecurity': 'true'})

    #enable kerberos on hbase
    cluster.get_service("hbase").update_config({'hbase_security_authentication': 'kerberos',
                                                'hbase_security_authorization': 'true',
                                                'hbase_superuser': 'hadoop.admin'})

    #Wait for all gen_credentials to be finished.
    while True:
        gcl = filter(lambda x: x.name =="GenerateCredentials" and x.active is True, cm.get_commands())
        if len(gcl) == 0:
            break
        time.sleep(5)

    cmd = cluster.deploy_client_config()
    if not cmd.wait(360).success:
        raise Exception("Failed to deploy client configurations")

    #redeploy configs
    #print "Starting Cluster.."
    # cmd = cm.get_service().start()
    # if not cmd.wait(720).success:
    #     raise Exception("Failed to start Management services!")
    # cmd = cluster.start()
    # if not cmd.wait(720).success:
    #     raise Exception("Failed to start Cluster")

enable_kerberos()
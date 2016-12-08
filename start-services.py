import os
import time
import json
from optparse import OptionParser
import ConfigParser
from cm_api.api_client import ApiResource
config = ConfigParser.ConfigParser()

def start_services():
    api = ApiResource('localhost', version=12)
    cm = api.get_cloudera_manager()

    cluster_config_file = open("/home/cloudera/kerberos-config.json")
    cluster_configs = json.load(cluster_config_file)
    cluster_name = cluster_configs["cluster_name"]
    cluster = api.get_cluster(cluster_name)

    print "Starting Cluster.."
    cmd = cm.get_service().start()
    if not cmd.wait(720).success:
        raise Exception("Failed to start Management services!")
    cmd = cluster.start()
    if not cmd.wait(720).success:
        raise Exception("Failed to start Cluster")

start_services()
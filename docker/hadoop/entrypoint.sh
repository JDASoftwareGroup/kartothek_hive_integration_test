#!/bin/bash

# Set some sensible defaults
export CORE_CONF_fs_defaultFS=${CORE_CONF_fs_defaultFS:-hdfs://`hostname -f`:8020}

# source common functions
source common.sh

configure /etc/hadoop/core-site.xml core CORE_CONF
configure /etc/hadoop/hdfs-site.xml hdfs HDFS_CONF
configure /etc/hadoop/yarn-site.xml yarn YARN_CONF
configure /etc/hadoop/httpfs-site.xml httpfs HTTPFS_CONF
configure /etc/hadoop/kms-site.xml kms KMS_CONF
configure /etc/hadoop/mapred-site.xml mapred MAPRED_CONF

if [ "$MULTIHOMED_NETWORK" = "1" ]; then
    echo "Configuring for multihomed network"

    # HDFS
    add_property /etc/hadoop/hdfs-site.xml dfs.namenode.rpc-bind-host 0.0.0.0
    add_property /etc/hadoop/hdfs-site.xml dfs.namenode.servicerpc-bind-host 0.0.0.0
    add_property /etc/hadoop/hdfs-site.xml dfs.namenode.http-bind-host 0.0.0.0
    add_property /etc/hadoop/hdfs-site.xml dfs.namenode.https-bind-host 0.0.0.0
    add_property /etc/hadoop/hdfs-site.xml dfs.client.use.datanode.hostname true
    add_property /etc/hadoop/hdfs-site.xml dfs.datanode.use.datanode.hostname true

    # YARN
    add_property /etc/hadoop/yarn-site.xml yarn.resourcemanager.bind-host 0.0.0.0
    add_property /etc/hadoop/yarn-site.xml yarn.nodemanager.bind-host 0.0.0.0
    add_property /etc/hadoop/yarn-site.xml yarn.nodemanager.bind-host 0.0.0.0
    add_property /etc/hadoop/yarn-site.xml yarn.timeline-service.bind-host 0.0.0.0

    # MAPRED
    add_property /etc/hadoop/mapred-site.xml yarn.nodemanager.bind-host 0.0.0.0
fi

if [ -n "$GANGLIA_HOST" ]; then
    mv /etc/hadoop/hadoop-metrics.properties /etc/hadoop/hadoop-metrics.properties.orig
    mv /etc/hadoop/hadoop-metrics2.properties /etc/hadoop/hadoop-metrics2.properties.orig

    for module in mapred jvm rpc ugi; do
        echo "$module.class=org.apache.hadoop.metrics.ganglia.GangliaContext31"
        echo "$module.period=10"
        echo "$module.servers=$GANGLIA_HOST:8649"
    done > /etc/hadoop/hadoop-metrics.properties
    
    for module in namenode datanode resourcemanager nodemanager mrappmaster jobhistoryserver; do
        echo "$module.sink.ganglia.class=org.apache.hadoop.metrics2.sink.ganglia.GangliaSink31"
        echo "$module.sink.ganglia.period=10"
        echo "$module.sink.ganglia.supportsparse=true"
        echo "$module.sink.ganglia.slope=jvm.metrics.gcCount=zero,jvm.metrics.memHeapUsedM=both"
        echo "$module.sink.ganglia.dmax=jvm.metrics.threadsBlocked=70,jvm.metrics.memHeapUsedM=40"
        echo "$module.sink.ganglia.servers=$GANGLIA_HOST:8649"
    done > /etc/hadoop/hadoop-metrics2.properties
fi

for i in ${SERVICE_PRECONDITION[@]}
do
    wait_for_it ${i}
done

exec $@

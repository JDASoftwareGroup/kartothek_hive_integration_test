# Kartothek HIVE integration Docker

## Quick Start

Execute the `before_intall.sh` to install the base Hadoop image.

To deploy docker cluster, run:
```
  docker-compose up -d
```

Once the build is completed and services start we will have the below services,

* Namenode
* Datanode
* Hive-server
* Hive-metastore
* Hive-metastore-postgresql
* test-executor

The `test-executor` service pulls in the latest version of kartothek and creates a dataset. 
This dataset is persisted into HIVE table and validated for datatypes between HIVE output and Kartothek Dataset.


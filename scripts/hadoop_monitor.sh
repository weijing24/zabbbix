#!/bin/bash

#item=$1
/usr/local/hadoop-2.3.0-cdh5.1.2/bin/hdfs dfsadmin -report|grep -w "Live datanodes"|grep -o "[0-9]\+"

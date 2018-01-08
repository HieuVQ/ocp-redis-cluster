#!/bin/bash

NODE1_IP=$(/usr/bin/getent hosts redis-cluster-node01 | awk {' print $1 '})
NODE2_IP=$(/usr/bin/getent hosts redis-cluster-node02 | awk {' print $1 '})
NODE3_IP=$(/usr/bin/getent hosts redis-cluster-node03 | awk {' print $1 '})
NODE4_IP=$(/usr/bin/getent hosts redis-cluster-node04 | awk {' print $1 '})
NODE5_IP=$(/usr/bin/getent hosts redis-cluster-node05 | awk {' print $1 '})
NODE6_IP=$(/usr/bin/getent hosts redis-cluster-node06 | awk {' print $1 '})
NODE1=$NODE1_IP":6379"
NODE2=$NODE2_IP":6379"
NODE3=$NODE3_IP":6379"
NODE4=$NODE4_IP":6379"
NODE5=$NODE5_IP":6379"
NODE6=$NODE6_IP":6379"

#NODE1="redis-cluster-node01:6379"
#NODE2="redis-cluster-node02:6379"
#NODE3="redis-cluster-node03:6379"
#NODE4="redis-cluster-node04:6379"
#NODE5="redis-cluster-node05:6379"
#NODE6="redis-cluster-node06:6379"

sleep 90

/usr/local/bin/redis-trib.rb create --replicas 1 $NODE1 $NODE2 $NODE3 $NODE4 $NODE5 $NODE6
echo RICARDO
exit 0

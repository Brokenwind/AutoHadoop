#!/bin/bash

ACTION=$1
IMAGE=hadoop-cluster
echo "$ACTION the hadoop cluster"

# get the containers based on image "hadoop-cluster"
names=(`docker ps -a | grep $IMAGE | awk '{print $1}'`)
for name in ${names[*]}
do
  if [ "$ACTION" == "delete" ]; then
    docker rm $name
  else
    docker $ACTION  $name
  fi
done

# get the number of datanode
declare -i num
num=${#names[@]}-1

if [ "$ACTION" == "start" ]; then
  # is the bridge br0 existed
  bridge=`brctl show | grep -w  br0`
  if [ ! "$bridge" == "" ]; then
    echo "delete original bridge br0"
    ip link set br0 down
    brctl delbr br0
  fi
  # set fixed ip for master
  pipework br0 master 192.168.1.10/24@192.168.1.1

  echo "set ip for datanodes.."
  for count in $(seq $num) 
  do
    nodename=slave$count
    addr=192.168.1.1$count
    if [ ! -d "/data/share/$nodename" ]; then
      mkdir /data/share/$nodename
    fi
    pipework br0 $nodename $addr/24@192.168.1.1
  done

# add addr for br0
  ip addr add 192.168.1.1/24 broadcast +1 dev br0
# copy host file to each container. when you restart your container, the hosts file return to default configuration
  for ((i=0; i<=$num; i++))
  do
    addr=192.168.1.1$i
    ./upload.sh $addr hosts  /etc/hosts
  done
fi

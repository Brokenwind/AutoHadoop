#!/bin/bash
name="iot"
rootpass="12072227"
norpass="19930309"
# the path we will use
jdkpath="/usr/local/java/"
hdpath="~/"
hdconpath=$hdpath"hadoop/etc/hadoop/"
home="~/"
# the names of archives we will upload
arcjdk="jdk-7u79-linux-x64.tar.gz"
archadoop="hadoop-2.6.0.tar.gz"
# the symbol link name
lnjdk="jdk"
lnhd="hadoop"
# get ips of hosts
ips=`cat hosts | awk '{if($1!="127.0.0.1") {print $1}}'`

for addr in $ips
do
    ./keys.sh $addr $name $norpass
done
# hosts of cluster login without passsword
if [ -f "authorized_keys" ]; then
  rm -f authorized_keys
fi
# download auth keys
for addr in $ips
do
  ./download.sh $addr $name $norpass "~/.ssh/id_rsa.pub" "./rsa_tmp"
  cat rsa_tmp >> authorized_keys
  rm -f rsa_tmp
done
# upload auth keys
for addr in $ips
do
    ./upload.sh $addr $name $norpass authorized_keys  "~/.ssh/"
    ./upload.sh $addr "root" $rootpass hosts  "/etc/hosts"
    ./upload.sh $addr $name $norpass hdconfig.sh  $home
    ./upload.sh $addr "root" $rootpass jdkconfig.sh  $home
done

# upload hadoop and jdk archives
for addr in $ips
do
#    ./send-cmd.sh $addr "root" $rootpass "mkdir "$jdkpath
#    ./upload.sh $addr $name $norpass $archadoop  $hdpath$archadoop
#    ./upload.sh $addr "root" $rootpass $arcjdk  $jdkpath$arcjdk
    ./send-cmd.sh $addr $name $norpass "./hdconfig.sh "$hdpath
    ./send-cmd.sh $addr "root" $rootpass "./jdkconfig.sh "$jdkpath
done

# upload hadoop configure files
for addr in $ips
do
    ./upload.sh $addr $name $norpass "core-site.xml" $hdconpath"core-site.xml"
    ./upload.sh $addr $name $norpass "hdfs-site.xml" $hdconpath"hdfs-site.xml"
    ./upload.sh $addr $name $norpass "mapred-site.xml" $hdconpath"mapred-site.xml"
    ./upload.sh $addr $name $norpass "yarn-site.xml" $hdconpath"yarn-site.xml"
    ./upload.sh $addr $name $norpass "slaves" $hdconpath"slaves"
done

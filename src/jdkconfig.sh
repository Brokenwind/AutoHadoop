#!/bin/bash

# the path where the jdk archive stored
jdkpath=$1
#jdk symbol link name
lnname="jdk"

if test -d $jdkpath
then
    arc=`ls $jdkpath | awk '/jdk.+tar.gz/'`
    if test -z $arc
    then
	echo "found no jdk archive"
	exit
    else
	# if there are many jdk archives,we just use the first
	arc=`echo $arc | awk '{print $1}'`
	tar -zxvf $jdkpath$arc -C $jdkpath
    fi
else
    echo "the path you input is not existed,please check it"
    exit
fi

jdks=`ls $jdkpath | awk '/jdk.+/'`
for jdk in $jdks
do
    if test -d $jdkpath$jdk
    then 
	echo $jdk
	ln -s $jdkpath$jdk $jdkpath$lnname
    fi
done

cat /etc/profile | grep JAVA_HOME
if test $? -ne 0
then
  echo 'export JAVA_HOME='$jdkpath$lnname >> /etc/profile
  echo 'export JRE_HOME=${JAVA_HOME}/jre' >> /etc/profile
  echo 'export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib' >> /etc/profile
  echo 'export PATH=${JAVA_HOME}/bin:${PATH}' >> /etc/profile
else
  echo "you have configured the java env"
fi
source /etc/profile
java -version
if test $? -ne 0
then
  echo "failed to configured the java"
else
  echo "correctly configured the java"
fi

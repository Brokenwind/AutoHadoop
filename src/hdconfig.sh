#!/bin/bash

# where the hadoop archive sotred
hdpath=$1
# the symbol name of hadoop directory
lnname="hadoop"

if test -d $hdpath
then
    arc=`ls $hdpath | awk '/hadoop.+tar.gz/'`
    if test -z $arc
    then
	echo "found no jdk archive"
	exit
    else
	# if there are many hadoop archives,we just use the first
	arc=`echo $arc | awk '{print $1}'`
	tar -zxvf $hdpath$arc -C $hdpath
    fi
else
    echo "the path you input is not existed,please check it"
    exit
fi

# remove the old hadoop symbole link
rm -rf $hdpath$lnname
dirs=`ls $hdpath | awk '/hadoop.+/'`
if test -z dirs
then
    echo "did get unziped hadoop archive directory"
    exit
else
    for dir in $dirs
    do
	if test -d $dir
	then
	    break
	fi
    done
    echo "current select hadoop directory is $dir"
    # create new symbol link
    ln -s $dir $hdpath$lnname
fi
# edit the haddop
sed -i "s?JAVA_HOME=\${JAVA_HOME}?JAVA_HOME=${JAVA_HOME}?g" $hdpath$lnname/etc/hadoop/hadoop-env.sh
# set environments
cat ~/.bash_profile | grep HADOOP_HOME
if test $? -eq 0
then
    echo "hadoop environment has been configured"
else
    echo "export HADOOP_HOME=$HOME/$lnname" >> ~/.bash_profile
    echo "export PATH=\${HADOOP_HOME}/bin:\${HADOOP_HOME}/sbin:\$PATH" >> ~/.bash_profile
    source ~/.bash_profile
fi
# create neccessary directories
mkdir ~/data/

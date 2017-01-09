# CentOS with JDK 7
# Author	amei

# build a new hadoop image with basic  centos 
FROM centos
# who is the author  
MAINTAINER amei

####################Configurate JDK################################
# install some important softwares , and make a new directory to store the jdk files
RUN yum -y install openssh-server openssh-clients  iproute  which  &&  mkdir /usr/local/java

# copy the jdk  archive to the image,and it will automaticlly unzip the tar file
ADD jdk-7u79-linux-x64.tar.gz /usr/local/java/

# make a symbol link adn set environment to .bash_profile 
RUN ln -s /usr/local/java/jdk1.7.0_79 /usr/local/java/jdk && \
 echo "export JAVA_HOME=/usr/local/java/jdk" >> /root/.bash_profile && \
 echo "export JRE_HOME=/usr/local/java/jdk/jre" >> /root/.bash_profile && \
 echo "export CLASSPATH=.:/usr/local/java/jdk/lib:/usr/local/java/jdk/jre/lib" >> /root/.bash_profile && \
 echo "export HADOOP_HOME=/usr/local/hadoop" >> /root/.bash_profile && \
 echo "export PATH=/usr/local/hadoop/bin:/usr/local/hadoop/sbin:/usr/local/java/jdk/bin:$PATH" >> /root/.bash_profile


###################Configurate SSH#################################
#generate key files
RUN ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N '' &&  ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' &&  ssh-keygen -q -t dsa -f /etc/ssh/ssh_host_ed25519_key  -N '' 

# login localhost without password
RUN ssh-keygen -f /root/.ssh/id_rsa -N '' &&  cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys


###################Configurate Hadoop##############################
# copy the hadoop  archive to the image,and it will automaticlly unzip the tar file
ADD hadoop-2.6.0.tar.gz /usr/local/

# make a symbol link
RUN ln -s /usr/local/hadoop-2.6.0 /usr/local/hadoop

# copy the configuration file to image
COPY core-site.xml /usr/local/hadoop/etc/hadoop/
COPY hdfs-site.xml /usr/local/hadoop/etc/hadoop/
COPY mapred-site.xml /usr/local/hadoop/etc/hadoop/
COPY yarn-site.xml /usr/local/hadoop/etc/hadoop/
COPY slaves /usr/local/hadoop/etc/hadoop/

# change hadoop environment variables
RUN sed -i "s?JAVA_HOME=\${JAVA_HOME}?JAVA_HOME=/usr/local/java/jdk?g" /usr/local/hadoop/etc/hadoop/hadoop-env.sh && \
 sed -i "s?#\s\+StrictHostKeyChecking\s\+ask?StrictHostKeyChecking no?g" /etc/ssh/ssh_config  && \
 sed -i "s?#UseDNS yes?UseDNS no?g" /etc/ssh/sshd_config 


################### Integration configuration #######################
# set environment variables
ENV JAVA_HOME /usr/local/java/jdk
ENV JRE_HOME ${JAVA_HOME}/jre
ENV CLASSPATH .:${JAVA_HOME}/lib:${JRE_HOME}/lib
ENV HADOOP_HOME /usr/local/hadoop
ENV PATH ${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${JAVA_HOME}/bin:$PATH

# set password of root
RUN echo "root:1234" | chpasswd
# when start a container it will be executed
CMD ["/usr/sbin/sshd","-D"]

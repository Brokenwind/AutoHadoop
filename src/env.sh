#!/usr/bin/expect -f

set addr [lindex $argv 0]
set name [lindex $argv 1]
set password [lindex $argv 2]
set jdkpath [lindex $argv 3]
# symbol link name
set lnname "jdk"
set timeout 30
# login
spawn ssh $name@$addr
expect {
    "*yes/no*" { send "yes\n"; exp_continue}
    "*password*" { send "$password\n" }
}
expect "*#*" { send "jdks=`ls \"$jdkpath\" | awk '/jdk*+/'`\n" }
# if you want to send $ to remote host you must add \
expect "*#*" { send "echo \$jdks \n" }
# remove old symbol link
expect "*#*" { send "
if test -L $jdkpath$lnname
then
  rm -rf $jdkpath$lnname
fi
\n" }
# add symbol link
expect "*#*" { send "
for jdk in \$jdks 
do
  if test -d $jdkpath\$jdk
  then 
    ln -s $jdkpath\$jdk $jdkpath$lnname
  fi
done
\n" }
# add environments
expect "*#*" { send "
cat /etc/profile | grep JAVA_HOME
if test \$? -ne 0
then
  echo \'export JAVA_HOME=/usr/local/java/jdk\' >> /etc/profile
  echo \'export JRE_HOME=\${JAVA_HOME}/jre\' >> /etc/profile
  echo \'export CLASSPATH=.:\${JAVA_HOME}/lib:\${JRE_HOME}/lib\' >> /etc/profile
  echo \'export PATH=\${JAVA_HOME}/bin:\${PATH}\' >> /etc/profile
else
  echo \"you have configured the java env\"
fi
source /etc/profile
java -version
if test \$? -ne 0
then
  echo \"failed to configured the java\"
else
  echo \"correctly configured the java\"
fi
\n"}
expect "*#*" { send "\n" }
#interact
send "exit\n"

#!/usr/bin/expect -f

set addr [lindex $argv 0]
set name [lindex $argv 1]
set password [lindex $argv 2]

# login
spawn ssh $name@$addr
expect {
    "*yes/no*" { send "yes\n"; exp_continue}
    "*password*" { send "$password\n" }
}
# generate auth key
expect {
    "*$*" {send "ssh-keygen -t rsa -P \"\"\n"}
    "*#*" {send "ssh-keygen -t rsa -P \"\"\n"}
}
expect "*ssh/id_rsa*" {send "\n"}
expect "*(y/n)*" {send "y\n"}

#interact
send "exit\n"

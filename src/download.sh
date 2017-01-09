#!/usr/bin/expect -f

set addr [lrange $argv 0 0]
set name [lrange $argv 1 1]
set password [lrange $argv 2 2]
set source_name [lrange $argv 3 3]
set dist_name [lrange $argv 4 4]

spawn scp $name@$addr:$source_name ./$dist_name
set timeout 30
expect {
  "yes/no" { send "yes\r"; exp_continue}
  "password:" { send "$password\r" }
}
send "exit\r"
expect eof 

#!/usr/bin/expect -f

set addr [lindex $argv 0]
set name [lindex $argv 1]
set password [lindex $argv 2]
set cmd [lindex $argv 3]

# login
set timeout 60
spawn ssh $name@$addr
expect {
    "*yes/no*" { send "yes\n"; exp_continue}
    "*password*" { send "$password\n" }
}
# send command
expect {
    "*]$*" { send $cmd\n }
    "*]#*" { send $cmd\n }
}

expect {
    "*]$*" { send "\n" }
    "*]#*" { send "\n" }
}
#interact
send "exit\n"
exit

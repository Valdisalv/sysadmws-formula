#!/bin/bash

cat > /etc/hosts <<- EOM
127.0.0.1   localhost
127.0.1.1   $1

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

#
$2 $3
EOM

cat > /etc/hostname <<- EOM
$1
EOM

/bin/hostname $(cat /etc/hostname)

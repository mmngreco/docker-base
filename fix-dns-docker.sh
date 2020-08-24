#!/bin/bash
# see https://serverfault.com/a/642984/573706
apt-get install bridge-utils
pkill docker
iptables -t nat -F
ifconfig docker0 down
brctl delbr docker0
service docker restart

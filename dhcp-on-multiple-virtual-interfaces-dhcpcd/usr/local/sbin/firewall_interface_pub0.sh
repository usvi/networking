#!/bin/sh

. /usr/local/sbin/networking_defs.sh


ADDR_PUB0=`/sbin/ip -o -4 addr list $IF_PUB0 | sed s/.*'inet '// | sed s/\\\/.*//`
ADDR_PUB_GW=`/sbin/ip -o -4 addr list $IF_PUB0 | sed s/.*'inet '// | sed s/\\\/.*//`


# Flush tables
/sbin/iptables -t nat -F "NAT_PREROUTING_$IF_PUB0"
/sbin/iptables -F "INPUT_$IF_PUB0"
/sbin/iptables -F "FORWARD_$IF_PUB0"
/sbin/iptables -t nat -F "NAT_POSTROUTING_$IF_PUB0"


# I personally use this script (firewall_interface_pub0.sh) to
# set up firewall in gateway mode for interface pub0.
# So basically just create simple nat
/sbin/iptables -t nat -A "NAT_POSTROUTING_$IF_PUB0" -o "$IF_PUB0" -j MASQUERADE
/sbin/iptables -A "FORWARD_$IF_PUB0" -i "$IF_PUB0" -o "$IF_LAN" -m state --state RELATED,ESTABLISHED -j ACCEPT
/sbin/iptables -A "INPUT_$IF_PUB0" -i "$IF_PUB0" -m state --state RELATED,ESTABLISHED -j ACCEPT

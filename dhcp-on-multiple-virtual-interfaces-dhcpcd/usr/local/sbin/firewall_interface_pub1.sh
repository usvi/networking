#!/bin/sh

. /usr/local/sbin/networking_defs.sh


ADDR_PUB1=`/sbin/ip -o -4 addr list $IF_PUB1 | sed s/.*'inet '// | sed s/\\\/.*//`
ADDR_PUB_GW=`/sbin/ip -o -4 addr list $IF_PUB0 | sed s/.*'inet '// | sed s/\\\/.*//`


# Flush tables
/sbin/iptables -t nat -F "NAT_PREROUTING_$IF_PUB1"
/sbin/iptables -F "INPUT_$IF_PUB1"
/sbin/iptables -F "FORWARD_$IF_PUB1"
/sbin/iptables -t nat -F "NAT_POSTROUTING_$IF_PUB1"


# Generics
/sbin/iptables -A "INPUT_$IF_PUB1" -i "$IF_PUB1" -d "$ADDR_PUB1" -m state --state RELATED,ESTABLISHED -j ACCEPT
/sbin/iptables -A "FORWARD_$IF_PUB1" -d "$ADDR_PRIV1" -j ACCEPT
/sbin/iptables -A "FORWARD_$IF_PUB1" -s "$ADDR_PRIV1" -j ACCEPT
/sbin/iptables -t nat -A "NAT_POSTROUTING_$IF_PUB1" -s "$ADDR_PRIV1" -j SNAT --to-source "$ADDR_PUB1"


# I personally use this script (firewall_interface_pub1.sh) to
# redirect all ports on an public interface to a local
# network SSH server 22, so here are the specific rules:
/sbin/iptables -t nat -A "NAT_PREROUTING_$IF_PUB1" -i "$IF_PUB1" -p tcp -d "$ADDR_PUB1" --dport 1:65535 -j DNAT --to-destination "$ADDR_PRIV1:22"
/sbin/iptables -t nat -A "NAT_PREROUTING_$IF_PUB1" -s "$RANGE_LAN" -d "$ADDR_PUB1" -p tcp --dport 1:65535 -j DNAT --to-destination "$ADDR_PRIV1:22"
/sbin/iptables -t nat -A "NAT_POSTROUTING_$IF_PUB1" -s "$RANGE_LAN" -d "$ADDR_PRIV1" -p tcp --dport 22 -j SNAT --to-source "$ADDR_PUB_GW"

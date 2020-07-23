#!/bin/sh

. /usr/local/sbin/networking_defs.sh


ADDR_PUB2=`/sbin/ip -o -4 addr list $IF_PUB2 | sed s/.*'inet '// | sed s/\\\/.*//`
ADDR_PUB_GW=`/sbin/ip -o -4 addr list $IF_PUB0 | sed s/.*'inet '// | sed s/\\\/.*//`


# Flush tables
/sbin/iptables -t nat -F "NAT_PREROUTING_$IF_PUB2"
/sbin/iptables -F "INPUT_$IF_PUB2"
/sbin/iptables -F "FORWARD_$IF_PUB2"
/sbin/iptables -t nat -F "NAT_POSTROUTING_$IF_PUB2"


# Generics
/sbin/iptables -A "INPUT_$IF_PUB2" -i "$IF_PUB2" -d "$ADDR_PUB2" -m state --state RELATED,ESTABLISHED -j ACCEPT
/sbin/iptables -A "FORWARD_$IF_PUB2" -d "$ADDR_PRIV2" -j ACCEPT
/sbin/iptables -A "FORWARD_$IF_PUB2" -s "$ADDR_PRIV2" -j ACCEPT
/sbin/iptables -t nat -A "NAT_POSTROUTING_$IF_PUB2" -s "$ADDR_PRIV2" -j SNAT --to-source "$ADDR_PUB2"


# I personally use this script (firewall_interface_pub2.sh) to
# redirect port 80 to a local network WWW server 80,
# so here are the specific rules:
/sbin/iptables -t nat -A "NAT_PREROUTING_$IF_PUB2" -i "$IF_PUB2" -p tcp -d "$ADDR_PUB2" --dport 80 -j DNAT --to-destination "$ADDR_PRIV2:80"
/sbin/iptables -t nat -A "NAT_PREROUTING_$IF_PUB2" -s "$RANGE_LAN" -d "$ADDR_PUB2" -p tcp --dport 80 -j DNAT --to-destination "$ADDR_PRIV2"
/sbin/iptables -t nat -A "NAT_POSTROUTING_$IF_PUB2" -s "$RANGE_LAN" -d "$ADDR_PRIV2" -p tcp --dport 80 -j SNAT --to-source "$ADDR_PUB_GW"

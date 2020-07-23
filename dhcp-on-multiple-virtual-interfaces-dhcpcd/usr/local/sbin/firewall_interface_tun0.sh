#!/bin/sh

. /usr/local/sbin/networking_defs.sh

ADDR_PUB_VPN=`/sbin/ip -o -4 addr list $IF_PUB0 | sed s/.*'inet '// | sed s/\\\/.*//`


# Flush tables
/sbin/iptables -t nat -F "NAT_PREROUTING_$IF_TUN"
/sbin/iptables -F "INPUT_$IF_TUN"
/sbin/iptables -F "FORWARD_$IF_TUN"
/sbin/iptables -t nat -F "NAT_POSTROUTING_$IF_TUN"


# Accept public interface VPN daemon connections to 443
/sbin/iptables -A "INPUT_$IF_TUN" -i "$IF_PUB0" -d "$ADDR_PUB_VPN" -m state --state NEW -p tcp --dport 443 -j ACCEPT


# Outbound connections via VPN
/sbin/iptables -A "INPUT_$IF_TUN" -i "$IF_TUN" -j ACCEPT
/sbin/iptables -A "FORWARD_$IF_TUN" -i "$IF_TUN" -j ACCEPT
/sbin/iptables -A "FORWARD_$IF_TUN" -i "$IF_PUB0" -o "$IF_TUN" -m state --state RELATED,ESTABLISHED -j ACCEPT
/sbin/iptables -A "FORWARD_$IF_TUN" -i "$IF_TUN" -o "$IF_PUB0" -m state --state RELATED,ESTABLISHED -j ACCEPT


# LAN connections
/sbin/iptables -A "FORWARD_$IF_TUN" -i "$IF_TUN" -o "$IF_LAN" -j ACCEPT
/sbin/iptables -t nat -A "NAT_POSTROUTING_$IF_TUN" -s "$RANGE_OPENVPN" -o "$IF_LAN" -j MASQUERADE
/sbin/iptables -A "FORWARD_$IF_TUN" -i "$IF_LAN" -o "$IF_TUN" -m state --state RELATED,ESTABLISHED -j ACCEPT


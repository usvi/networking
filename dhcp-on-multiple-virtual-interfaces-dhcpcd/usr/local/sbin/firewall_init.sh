#!/bin/sh

# This script is run from rc.local (and only once)

. /usr/local/sbin/networking_defs.sh


# Flush chains
/sbin/iptables -F
/sbin/iptables -X
/sbin/iptables -t nat -F
/sbin/iptables -t nat -X


# Create interface-based chains
/sbin/iptables -t nat -N "NAT_PREROUTING_$IF_PUB0"
/sbin/iptables -N "INPUT_$IF_PUB0"
/sbin/iptables -N "FORWARD_$IF_PUB0"
/sbin/iptables -t nat -N "NAT_POSTROUTING_$IF_PUB0"

/sbin/iptables -t nat -N "NAT_PREROUTING_$IF_PUB1"
/sbin/iptables -N "INPUT_$IF_PUB1"
/sbin/iptables -N "FORWARD_$IF_PUB1"
/sbin/iptables -t nat -N "NAT_POSTROUTING_$IF_PUB1"

/sbin/iptables -t nat -N "NAT_PREROUTING_$IF_PUB2"
/sbin/iptables -N "INPUT_$IF_PUB2"
/sbin/iptables -N "FORWARD_$IF_PUB2"
/sbin/iptables -t nat -N "NAT_POSTROUTING_$IF_PUB2"

#/sbin/iptables -t nat -N "NAT_PREROUTING_$IF_TUN"
#/sbin/iptables -N "INPUT_$IF_TUN"
#/sbin/iptables -N "FORWARD_$IF_TUN"
#/sbin/iptables -t nat -N "NAT_POSTROUTING_$IF_TUN"

# Drop everything by default
/sbin/iptables -P INPUT DROP
/sbin/iptables -P FORWARD DROP


# Allow outputs
/sbin/iptables -P OUTPUT ACCEPT


# Allow all on localhost
/sbin/iptables -A INPUT -i lo -j ACCEPT


# Allow local network (dont use sub-chains for only these two)
/sbin/iptables -A INPUT -i "$IF_LAN" -j ACCEPT
/sbin/iptables -A FORWARD -i "$IF_LAN" -o "$IF_PUB0" -j ACCEPT


# Visit interface-based rules
/sbin/iptables -t nat -A PREROUTING -j "NAT_PREROUTING_$IF_PUB0"
/sbin/iptables -A INPUT -j "INPUT_$IF_PUB0"
/sbin/iptables -A FORWARD -j "FORWARD_$IF_PUB0"
/sbin/iptables -t nat -A POSTROUTING -j "NAT_POSTROUTING_$IF_PUB0"

/sbin/iptables -t nat -A PREROUTING -j "NAT_PREROUTING_$IF_PUB1"
/sbin/iptables -A INPUT -j "INPUT_$IF_PUB1"
/sbin/iptables -A FORWARD -j "FORWARD_$IF_PUB1"
/sbin/iptables -t nat -A POSTROUTING -j "NAT_POSTROUTING_$IF_PUB1"

/sbin/iptables -t nat -A PREROUTING -j "NAT_PREROUTING_$IF_PUB2"
/sbin/iptables -A INPUT -j "INPUT_$IF_PUB2"
/sbin/iptables -A FORWARD -j "FORWARD_$IF_PUB2"
/sbin/iptables -t nat -A POSTROUTING -j "NAT_POSTROUTING_$IF_PUB2"

#/sbin/iptables -t nat -A PREROUTING -j "NAT_PREROUTING_$IF_TUN"
#/sbin/iptables -A INPUT -j "INPUT_$IF_TUN"
#/sbin/iptables -A FORWARD -j "FORWARD_$IF_TUN"
#/sbin/iptables -t nat -A POSTROUTING -j "NAT_POSTROUTING_$IF_TUN"

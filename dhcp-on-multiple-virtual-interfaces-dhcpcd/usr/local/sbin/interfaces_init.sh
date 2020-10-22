#!/bin/sh

# This script is run from rc.local (and only once)

. /usr/local/sbin/networking_defs.sh

rm -rf "$SCRIPTS_LOCKDIR"

# Create the virtual interfaces
ip link set "$IF_VIRTUAL_BASE" up

ethtool --offload "$IF_VIRTUAL_BASE" rx off tx off
ethtool --offload enp3s0 rx off tx off

ip link set "$IF_VIRTUAL_BASE" promisc on
ip link add link "$IF_VIRTUAL_BASE" address 00:91:2e:4d:43:67 "$IF_PUB0" type macvlan
ip link set "$IF_PUB0" up
ip link add link "$IF_VIRTUAL_BASE" address 00:92:2e:4d:43:67 "$IF_PUB1" type macvlan
ip link set "$IF_PUB1" up
#ip link add link "$IF_VIRTUAL_BASE" address 00:93:2e:4d:43:67 "$IF_PUB2" type macvlan
#ip link set "$IF_PUB2" up

# Enable forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

#!/bin/sh

# This script is run from rc.local (and only once)

. /usr/local/sbin/networking_defs.sh

rm -rf "$SCRIPTS_LOCKDIR"

# Create the virtual interfaces
ip link set "$IF_VIRTUAL_BASE" up
ip link add link "$IF_VIRTUAL_BASE" address 00:1d:b9:57:9b:8c "$IF_PUB0" type macvlan
ip link set "$IF_PUB0" up
ip link add link "$IF_VIRTUAL_BASE" address 00:2d:b9:57:9b:8c "$IF_PUB1" type macvlan
ip link set "$IF_PUB1" up
ip link add link "$IF_VIRTUAL_BASE" address 00:3d:b9:57:9b:8c "$IF_PUB2" type macvlan
ip link set "$IF_PUB2" up

# Enable forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

#!/bin/bash
INTERFACE=$1

. /usr/local/sbin/networking_defs.sh


if [ -z "$INTERFACE" ];
then
    echo "No interface given!"
    exit 1
fi


GATEWAY=$(head -n 1 "$ROUTE_INFO_PATH/$INTERFACE.dat")
if [ -z "$GATEWAY" ];
then
    echo "Could not get gateway address!"
    exit 1
fi


# Figure out interface ip
IPADDR=$(get_ip_for_interface "$INTERFACE")
if [ -z "$IPADDR" ]; then
    echo "Could not get IP address of interface!"
    exit 1;
fi


# Get the network in 12.34.56.0/24 form
ID_NETWORK=$(get_network_for_interface "$INTERFACE")
if [ -z "$ID_NETWORK" ]; then
    echo "Could not get network of interface!"
    exit 1;
fi



# Flush old values
ip route flush table "$INTERFACE"

while ip rule show | grep "lookup $INTERFACE" &>/dev/null; do
    ip rule del table "$INTERFACE"
done


# Set new policy routing
ip route add "$ID_NETWORK" dev "$INTERFACE" src "$IPADDR" table "$INTERFACE"
ip route add default via "$GATEWAY" dev "$INTERFACE" table "$INTERFACE"
ip rule add from "$IPADDR/32" table "$INTERFACE"
ip rule add to "$IPADDR/32" table "$INTERFACE"

# Set additional lookups
# For interface 1
if [ "$INTERFACE" = "$IF_PUB1" ];
then
    # Remove rules for LAN
    while ip rule show | grep "$ADDR_PRIV1.*$RANGE_LAN" &>/dev/null; do
        ip rule delete from "$ADDR_PRIV1" to "$RANGE_LAN"
    done
    # Use specific lookup table for interface 1
    ip rule add from "$ADDR_PRIV1" lookup "$IF_PUB1"
    # But use main lookup table for LAN stuff
    ip rule add from "$ADDR_PRIV1" to "$RANGE_LAN" lookup main
fi
# For interface 2
if [ "$INTERFACE" = "$IF_PUB2" ];
then
    # Remove rules for LAN
    while ip rule show | grep "$ADDR_PRIV2.*$RANGE_LAN" &>/dev/null; do
        ip rule delete from "$ADDR_PRIV2" to "$RANGE_LAN"
    done
    # Use specific lookup table for interface 2
    ip rule add from "$ADDR_PRIV2" lookup "$IF_PUB2"
    # But use main lookup table for LAN stuff
    ip rule add from "$ADDR_PRIV2" to "$RANGE_LAN" lookup main
fi


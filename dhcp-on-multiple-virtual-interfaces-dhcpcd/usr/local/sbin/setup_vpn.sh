#!/bin/sh

. /usr/local/sbin/networking_defs.sh

ADDR_PUB_VPN=$(get_ip_for_interface "$IF_PUB0")
OPENVPN_CONF_LISTEN="/etc/openvpn/listen.conf"

echo "# Include this to openvpn confs via" > "$OPENVPN_CONF_LISTEN"
echo "# config /etc/openvpn/listen.conf" >> "$OPENVPN_CONF_LISTEN"
echo "#" >> "$OPENVPN_CONF_LISTEN"
echo "local $ADDR_PUB_VPN" >> "$OPENVPN_CONF_LISTEN"
service openvpn restart

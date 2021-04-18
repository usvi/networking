#!/bin/sh

# Names for interfaces
# Virtual interface for macvlan magic
IF_VIRTUAL_BASE=enp1s0
# IF_PUB0 is explicit GW in scripts
IF_PUB0=virtual0
IF_PUB1=virtual1
IF_PUB2=virtual2
IF_LAN=enp2s0
# For Openvpn
IF_TUN=tun0

# LAN-side corresponding addresses and ranges
ADDR_PRIV0=172.16.8.254
ADDR_PRIV1=172.16.8.162
ADDR_PRIV2=172.16.8.161
RANGE_LAN=172.16.8.0/24
RANGE_OPENVPN=172.16.8.0/28

# Dy.fi names
IF_PUB0_DY_NAME=gw.asuka.dy.fi
IF_PUB1_DY_NAME=shell.asuka.dy.fi
IF_PUB2_DY_NAME=asuka.dy.fi

# Other settings
ROUTE_INFO_PATH=/var/lib/routes
SCRIPTS_LOCKDIR="$ROUTE_INFO_PATH/lock"
NEW_ROUTERS_TIME_TRESHOLD=60
LOCK_WAIT_MAX_SECS=30

# USE flags: Define non-zero if want enabled
USE_DY_FI="yes"
USE_OPENVPN="no"

try_lock ()
{
    LOCK_INTERFACE="$1"
    LOCK_TRY_TIME=0

    #logger "Interface $LOCK_INTERFACE trying to get a lock"
    
    while [ "$LOCK_TRY_TIME" -lt "$LOCK_WAIT_MAX_SECS" ];
    do
	if mkdir "$SCRIPTS_LOCKDIR";
	then
	    # Lock acquired
	    break;
	else
	    # Lock not acquired, wait and try again
	    sleep 1;
	    LOCK_TRY_TIME=$(( LOCK_TRY_TIME+1 ));
	fi
    done

    if [ "$LOCK_TRY_TIME" -ge "$LOCK_WAIT_MAX_SECS" ];
    then
	logger "Interface $LOCK_INTERFACE could not get a lock! Exiting.";
	exit 1;
    fi
    #logger "Interface $LOCK_INTERFACE got a lock"
}


drop_lock ()
{
    LOCK_INTERFACE="$1"

    #logger "Interface $LOCK_INTERFACE releasing locking";
    rmdir "$SCRIPTS_LOCKDIR";
}


if_has_ip ()
{
    PARAM_INTERFACE="$1"
    TEST_IP=`/sbin/ip -o -4 addr list $PARAM_INTERFACE | head -n 1 | sed s/.*'inet '// | sed s/\\\/.*//`

    if [ -z "$TEST_IP" ];
    then
	echo "0"
    else
	echo "1"
    fi
}

get_ip_for_interface ()
{
    PARAM_INTERFACE="$1"
    IP=`/sbin/ip -o -4 addr list $PARAM_INTERFACE | head -n 1 | sed s/.*'inet '// | sed s/\\\/.*//`

    echo "$IP"
}

get_network_for_interface ()
{
    PARAM_INTERFACE="$1"
    FULL_IP=`/sbin/ip -o -4 addr list $PARAM_INTERFACE | head -n 1 | sed s/.*'inet '// | sed s/\\\/.*//`
    SHORT_MASK=`/sbin/ip -o -4 addr list $PARAM_INTERFACE | head -n 1 | sed s/.*\\\/// | sed s/\\ .*//`
    SHIFT_BITS="$((32 - $SHORT_MASK))"

    # Full mask
    MASK_BITS="4294967295"
    MASK_BITS="$(($MASK_BITS >> $SHIFT_BITS))"
    MASK_BITS="$(($MASK_BITS << $SHIFT_BITS))"

IFS='.' read -r IP1 IP2 IP3 IP4 <<EOF
$FULL_IP
EOF


    IP_BITS="$(($IP1))"
    IP_BITS="$((($IP_BITS << 8) + $IP2))"
    IP_BITS="$((($IP_BITS << 8) + $IP3))"
    IP_BITS="$((($IP_BITS << 8) + $IP4))"

    NETWORK_BITS="$(($MASK_BITS & $IP_BITS))"
    IP4="$((($NETWORK_BITS >> 0) & 255))"
    IP3="$((($NETWORK_BITS >> 8) & 255))"
    IP2="$((($NETWORK_BITS >> 16) & 255))"
    IP1="$((($NETWORK_BITS >> 24) & 255))"

    echo "$IP1.$IP2.$IP3.$IP4/$SHORT_MASK"
}

#!/bin/sh

# Names for interfaces
# Virtual interface for macvlan magic
IF_VIRTUAL_BASE=enp4s0
# IF_PUB0 is explicit GW in scripts
IF_PUB0=virtual0
IF_PUB1=virtual1
IF_PUB2=virtual2
IF_LAN=enp3s0
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


get_gw_for_interface ()
{
    PARAM_INTERFACE="$1"
    GW=`/sbin/ip -o -4 addr list $PARAM_INTERFACE | head -n 1 | sed s/.*'inet '// | sed s/\\\/.*//`

    echo "$GW"
}

get_ip_and_mask_for_interface ()
{
    PARAM_INTERFACE="$1"
    IP_AND_MASK=`/sbin/ip -o -4 addr list virtual0 | head -n 1 | sed s/.*'inet '// | sed s/\\\ .*//`

    echo "$IP_AND_MASK"
}

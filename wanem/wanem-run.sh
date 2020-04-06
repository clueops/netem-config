#!/bin/bash

# WanEm - wanem-run.sh
# Script to create a NetEm environment to emulate a WAN

: '
 Script usage:
 ./wanem-run.sh			        	: output to screen only
 ./wanem-run.sh | tee <logfile.log>	: output to screen and log file <logfile.log>
'

# Load parameters file with required variables
source wanem-config.sh

# Start WanEm run here
echo "Starting WanEm run..."
echo $(date -u)

# Remove any pre-existing active NetEm config
sudo tc qdisc del dev $in_interface root
sudo tc qdisc del dev $out_interface root

# Create 3-class priority map (0,1,2), with all traffic redirected to the third class (id 2) by default.
sudo tc qdisc add dev $in_interface root handle 1: prio bands 3 priomap 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
sudo tc qdisc add dev $out_interface root handle 1: prio bands 3 priomap 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2

# 1. Create LAN zone conditions
    # First class (prior, id 0) uses normal queuing (fifo)
    sudo tc qdisc add dev $in_interface parent 1:1 handle 10: pfifo
    sudo tc qdisc add dev $out_interface parent 1:1 handle 10: pfifo

    # Traffic filters - loop through each IP in LAN zone
    echo $lan_filters
    for lan_ip in $lan_filters
    do
        echo $lan_ip
        # Apply traffic filters - Inbound
        sudo tc filter add dev $in_interface protocol ip parent 1: prio 1 u32 match ip src $lan_ip flowid 1:1
        # Apply traffic filters - Outbound
        sudo tc filter add dev $out_interface protocol ip parent 1: prio 1 u32 match ip dst $lan_ip flowid 1:1
    done

# 2. Create WAN zone conditions
    # Second class (id 1) uses the specific impairment configuration (20:)
    sudo tc qdisc add dev $in_interface parent 1:2 handle 20: netem delay $((wan_delay/2))ms
    sudo tc qdisc add dev $out_interface parent 1:2 handle 20: netem delay $((wan_delay/2))ms

    # Traffic filters - loop through each IP in WAN zone
    echo $wan_filters
    for wan_ip in $wan_filters
    do
        echo $wan_ip
        # Apply traffic filters - Inbound
        sudo tc filter add dev $in_interface protocol ip parent 1: prio 2 u32 match ip src $wan_ip flowid 1:2
        # Apply traffic filters - Outbound
        sudo tc filter add dev $out_interface protocol ip parent 1: prio 2 u32 match ip dst $wan_ip flowid 1:2
    done

# 3. Create WAN zone conditions
    # Third class (default, id 2) uses the specific impairment configuration (30:)
    sudo tc qdisc add dev $in_interface parent 1:3 handle 30: netem delay $((int_delay/2))ms
    sudo tc qdisc add dev $out_interface parent 1:3 handle 30: netem delay $((int_delay/2))ms

    # Traffic filters - no need to apply a filter, this class is applied to all IPs not previously allocated to the LAN or WAN zones

sudo tc qdisc show dev $in_interface
sudo tc qdisc show dev $out_interface


# Finish
echo ""
echo $(date -u)
echo "Finished WanEm run!"


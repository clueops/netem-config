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

# Create LAN zone conditions
    # First class (prior, id 0) uses normal queuing (fifo)
    sudo tc qdisc add dev $in_interface parent 1:1 handle 10: pfifo
    sudo tc qdisc add dev $out_interface parent 1:1 handle 10: pfifo

    # Traffic filters - loop through each IP in LAN zone
    for lan_ip in $lan_filters
    do
        # Apply traffic filters - Inbound
        sudo tc filter add dev $in_interface protocol ip parent 1: prio 3 u32 match ip src $lan_ip flowid 1:1
        # Apply traffic filters - Outbound
        sudo tc filter add dev $out_interface protocol ip parent 1: prio 3 u32 match ip dst $lan_ip flowid 1:1
    done

    sudo tc qdisc show dev $in_interface
    sudo tc qdisc show dev $out_interface

# Finish
echo ""
echo $(date -u)
echo "Finished WanEm run!"


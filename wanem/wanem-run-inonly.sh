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
# sudo tc qdisc add dev $out_interface root handle 1: prio bands 3 priomap 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2

# 1. Create LAN zone conditions
    # First class (prior, id 0) uses normal queuing (fifo), no impairments

    # Add a new NetEm qdisc with impairments on Inside interface (for inbound traffic)
    sudo tc qdisc add dev $in_interface parent 1:1 handle 10: pfifo

    # Traffic filters - loop through each IP in LAN zone
    for lan_ip in $lan_filters
    do
        # Apply traffic filters - Inbound
        sudo tc filter add dev $in_interface protocol ip parent 1: prio 1 u32 match ip src $lan_ip flowid 1:1
    done

# 2. Create WAN zone conditions
    # Second class (id 1) uses the specific impairment configuration (20:)
    echo "WAN conditions:" $wan_delay $wan_jitter $wan_loss

    # Add a new NetEm qdisc with delay and loss impairments on Inside interface (for inbound traffic)
    sudo tc qdisc add dev $in_interface parent 1:2 handle 20: netem delay ${wan_delay}ms loss $wan_loss

    # Apply jitter if specified and we only want to apply +ve jitter (i.e. we don't want the resulting delay to be less than the base delay for this zone)
    # Half the jitter value is applied as additional latency, half is applied as jitter on this additional latency. Not perfect but reasonable approximation.
    if [ $wan_jitter -ne 0 ]
    then
        # Add a second chained NetEm qdsic on Inside interface with jitter impairment
		sudo tc qdisc add dev $in_interface parent 20: handle 21: netem delay $((wan_jitter/2))ms $((wan_jitter/2))ms
    fi

    # Traffic filters - loop through each IP in WAN zone
    for wan_ip in $wan_filters
    do
        # Apply traffic filters - Inbound
        sudo tc filter add dev $in_interface protocol ip parent 1: prio 2 u32 match ip src $wan_ip flowid 1:2
    done

# 3. Create Internet zone conditions
    # Third class (default, id 2) uses the specific impairment configuration (30:)

    # Aggregate the total WAN and Internet conditions
    int_delay=$((wan_delay + int_delay))
    int_jitter=$((wan_jitter + int_jitter))
    int_loss=$((wan_loss + int_loss))
    echo "INT conditions:" $int_delay $int_jitter $int_loss

    # Add a new NetEm qdisc with delay and loss impairments on Inside interface (for inbound traffic)
    sudo tc qdisc add dev $in_interface parent 1:3 handle 30: netem delay ${int_delay}ms loss $int_loss

    # Apply jitter if specified and we only want to apply +ve jitter (i.e. we don't want the resulting delay to be less than the base delay for this zone)
    # Half the jitter value is applied as additional latency, half is applied as jitter on this additional latency. Not perfect but reasonable approximation.
    if [ $int_jitter -ne 0 ]
    then
        # Add a second chained NetEm qdsic on Inside interface with jitter impairment
		sudo tc qdisc add dev $in_interface parent 30: handle 31: netem delay $((int_jitter/2))ms $((int_jitter/2))ms
    fi

    # Traffic filters - 
    # Not required for Internet Zone, this is the default class and applied to all IPs not previously allocated to the LAN or WAN zones

# Finish
sudo tc qdisc show dev $in_interface
sudo tc qdisc show dev $out_interface

echo ""
echo $(date -u)
echo "Finished WanEm run!"


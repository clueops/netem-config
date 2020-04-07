#!/bin/bash

# wanem-config.sh
# Parameter variables for use by 'wanem-run.sh' script

# Set Interface to required network interface
# Options: Inside [enp1s0f1], Outside: [enp1s0f0]
in_interface=enp1s0f1
out_interface=enp1s0f0

# LAN Zone
    # Conditions (qdisc 10:)
        # No added behaviourimpairments for LAN devices
    # Filters (class/flowid 1:1)
        lan_filters="14.1.1.1/32 11.1.1.70/32 11.1.1.3/32"

# WAN Zone
    # Conditions (qdisc 20:, 21:)
        wan_delay="10"      # Specify value of Delay to use (in 'ms') - value will be applied 100% to in
        wan_jitter="0"      # Specify value of Jitter to use (in 'ms') - value will be applied 100% to in
        wan_loss="0"        # Specify value of Loss to use (in '%') - value will be applied 100% to in
    # Filters (class/flowid 1:2)
        wan_filters="11.1.1.2/32 12.0.0.10/32 172.16.0.1/32"

# Internet Zone
    # Conditions (qdisc 30:, 31:)
        # Note that these conditions are *additive* to the WAN conditions above (and any underlying Internet latency)
        int_delay="0"      # Specify value of Delay to use (in 'ms') - value will be applied 100% to in
        int_jitter="0"      # Specify value of Jitter to use (in 'ms') - value will be applied 100% to in
        int_loss="0"        # Specify value of Loss to use (in '%') - value will be applied 100% to in
    # Filters (class/flowid 1:3)
        int_filters=""      # default - everything else

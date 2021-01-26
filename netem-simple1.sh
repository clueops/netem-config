#!/bin/bash
# Script to drive NetEm and provide changing network conditions
# Scenario 1: Default traffic impaired, only certain DST IP unaffected

# Useing Inside interface only (for inbound traffic)

# Clear any existing qdisc devices
/sbin/tc qdisc del dev enp1s0f1 root

# Create 2-class priority map (0,1), with all traffic redirected to the second class (id 1, qdisc 1:2) by default.
/sbin/tc qdisc add dev enp1s0f1 root handle 1: prio bands 2 priomap 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1

# Add a new NetEm qdisc 1:1 with no impairments
/sbin/tc qdisc add dev enp1s0f1 parent 1:1 handle 10: pfifo limit 1000

# Add a new NetEm qdisc 1:2 with delay and loss impairments on Inside interface (for inbound traffic)
/sbin/tc qdisc add dev enp1s0f1 parent 1:2 handle 20: netem delay 10ms 10ms 25% distribution normal loss 25

# Default behaviour is all traffic is sent to qdisc 1:2 and is impaired

# Filter traffic to qdisc 1:1 to avoid any impairment
# Exclude the IP address of the first hops
# /sbin/tc filter add dev ens3 protocol ip parent 1: prio 3 u32 match ip dst 140.91.204.0/24 flowid 1:1
# /sbin/tc filter add dev ens3 protocol ip parent 1: prio 3 u32 match ip dst 59.144.81.10/32 flowid 1:1


# # Leave the new network conditions in place for agreed time duration (60 minutes)
sleep 3000

# Remove qdisc devices
/sbin/tc qdisc del dev enp1s0f1 root

#end
#!/bin/bash
# Script to drive NetEm and provide changing network conditions on a schedule
# Scenario 2: Default traffic unaffected, only certain DST IP with impairment

# Create qdisc devices
/sbin/tc qdisc del dev ens4 root
/sbin/tc qdisc add dev ens4 root handle 1: prio bands 2 priomap 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
/sbin/tc qdisc add dev ens4 parent 1:1 handle 10: netem delay 50ms 50ms 25% distribution normal loss 5
/sbin/tc qdisc add dev ens4 parent 1:2 handle 20: pfifo

# Filter traffic to qdisc 1:1 to add the impairments
# Web App 4 – NAPM login
/sbin/tc filter add dev ens4 protocol ip parent 1: prio 3 u32 match ip dst 69.175.34.70/32 flowid 1:1

# Default all other traffic to qdisc 1:2 with no impairment

# Leave the new network conditions in place for agreed time duration (e.g. 15 minutes)
sleep 900

# Remove qdisc devices
/sbin/tc qdisc del dev ens4 root

#end
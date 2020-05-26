#!/bin/bash
# Script to drive NetEm and provide changing network conditions on a schedule
# Scenario 1: Default traffic impaired, only certain DST IP unaffected (e.g. trying for 1st hop)

# Create qdisc devices
/sbin/tc qdisc del dev ens3 root
/sbin/tc qdisc add dev ens3 root handle 1: prio bands 2 priomap 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
/sbin/tc qdisc add dev ens3 parent 1:1 handle 10: pfifo limit 1000
/sbin/tc qdisc add dev ens3 parent 1:2 handle 20: netem delay 50ms 30ms 25% distribution normal loss 5

# Default behaviour is all traffic is sent to qdisc 1:2 and is impaired

# Filter traffic to qdisc 1:1 to avoid any impairment
# Exclude the IP address of the first hops
/sbin/tc filter add dev ens3 protocol ip parent 1: prio 3 u32 match ip dst 140.91.204.0/24 flowid 1:1
/sbin/tc filter add dev ens3 protocol ip parent 1: prio 3 u32 match ip dst 59.144.81.10/32 flowid 1:1


# # Leave the new network conditions in place for agreed time duration (60 minutes)
sleep 3000

# Remove qdisc devices
/sbin/tc qdisc del dev ens3 root

#end
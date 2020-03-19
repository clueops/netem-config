#!/bin/bash

# Script to drive NetEm and provide changing network conditions on a schedule

in_interface=enp1s0f1
out_interface=enp1s0f0

sudo tc qdisc del dev $in_interface root
sudo tc qdisc del dev $out_interface root

sudo tc qdisc add dev $in_interface root handle 1: prio bands 2 priomap 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
sudo tc qdisc add dev $out_interface root handle 1: prio bands 2 priomap 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1

sudo tc qdisc add dev $in_interface parent 1:1 handle 10: pfifo
sudo tc qdisc add dev $in_interface parent 1:2 handle 20: netem delay 50ms 20ms 25% distribution normal loss 5

sudo tc qdisc add dev $out_interface parent 1:1 handle 10: pfifo
sudo tc qdisc add dev $out_interface parent 1:2 handle 20: netem delay 50ms 20ms 25% distribution normal loss 5

sudo tc filter add dev $in_interface protocol ip parent 1: prio 3 u32 match ip src 14.1.1.1/32 flowid 1:1
sudo tc filter add dev $in_interface protocol ip parent 1: prio 3 u32 match ip src 11.1.1.70/32 flowid 1:1

sudo tc filter add dev $out_interface protocol ip parent 1: prio 3 u32 match ip dst 14.1.1.1/32 flowid 1:1
sudo tc filter add dev $out_interface protocol ip parent 1: prio 3 u32 match ip dst 11.1.1.70/32 flowid 1:1

sudo tc qdisc show dev $in_interface 
sudo tc class show dev $in_interface 
sudo tc qdisc show dev $out_interface 
sudo tc class show dev $out_interface 
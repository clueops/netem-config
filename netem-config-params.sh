#!/bin/bash

# Parameter variables for use by 'netem-config-run.sh' script

# Set Duration to required number of SECONDS (e.g. 1200 is 20 minutes)
DURATION=2

# Set Interface to required network interface
# Options: Inside [enp1s0f1], Outside: [enp1s0f0]
IN_INTERFACE=enp1s0f1
OUT_INTERFACE=enp1s0f0

# Specify values of Delay to use (in 'ms')
DELAY_PARAMS="1 30 80 130 180 230"

# Specify values of Jitter to use (in 'ms')
JITTER_PARAMS="0 20 50 100"

# Specify values of Loss to use (in '%')
LOSS_PARAMS="0 2 5 10 15"
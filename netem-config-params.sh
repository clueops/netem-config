#!/bin/bash

# Parameter variables for use by 'netem-config-run.sh' script

# Set Duration to required number of SECONDS (e.g. 1200 is 20 minutes)
duration=2

# Set default behaviour to loop through these values in the order they appear in the variable (i.e. not randomised/shuffled)
random="no"

# Set Interface to required network interface
# Options: Inside [enp1s0f1], Outside: [enp1s0f0]
in_interface=enp1s0f1
out_interface=enp1s0f0

# Specify values of Delay to use (in 'ms')
delay_params="1 30 80 130 180 230"

# Specify values of Jitter to use (in 'ms')
jitter_params="0 20 50 100"

# Specify values of Loss to use (in '%')
loss_params="0 2 5 10 15"
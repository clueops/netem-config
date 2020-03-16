#!/bin/bash

# Script to drive NetEm to provide changing network conditions

# usage:
# ./netem-config-run.sh			        	: output to screen only
# ./netem-config-run.sh | tee <logfile.log>	: output to screen and log file <logfile.log>

# Call parameters file and required variables
source netem-config-params.sh

# Set variables to use for this run
DELAY_RUN = $DELAY_PARAMS
JITTER_RUN = $JITTER_PARAMS
LOSS_RUN = $LOSS_PARAMS

# Start run
echo "Starting NetEm run..."
echo $(date -u)

# Remove any pre-existing active netem config
# sudo tc qdisc del dev $IN_INTERFACE root
# sudo tc qdisc del dev $OUT_INTERFACE root

# Main loops start here - loop by Delay > Jitter > Loss

# Delay loop
for DELAY in $DELAY_RUN
do
    echo ""
    echo "- Delay is ${DELAY}ms"
    IN_DELAY="$((DELAY/2))ms"
    OUT_DELAY="$((DELAY/2))ms"

    # Jitter loop
    for JITTER in $JITTER_RUN
    do
        JITTER="${JITTER}ms"
        echo "  - Jitter is $JITTER"

        # Loss loop
        for LOSS in $LOSS_RUN
        do
            echo "    - Loss is ${LOSS}%"

            # Set new netem conditions on Inside interface (for inbound traffic)
            if [ $JITTER = 0 ]
		    then
#			    sudo tc qdisc add dev $IN_INTERFACE root netem delay $IN_DELAY loss $LOSS
		    else
#			    sudo tc qdisc add dev $IN_INTERFACE root netem delay $IN_DELAY $JITTER 25% distribution normal loss $LOSS
		    fi

            # Set new netem conditions on Outside interface (for outbound traffic)
#            sudo tc qdisc add dev $OUT_INTERFACE root netem delay $OUT_DELAY

            # Display current netem conditions (sanity check)
            echo -n "        * $(date -u)"
            sudo tc qdisc show dev $IN_INTERFACE | awk '{print "  : IN   ->   "$0}'
            echo -n "        * $(date -u)"
            sudo tc qdisc show dev $OUT_INTERFACE | awk '{print "  : OUT   ->   "$0}'
            
            # Leave the new network conditions in place for agreed time duration
            sleep $DURATION
            # Remove the current netem config in preparation for next loop (netem does not allow changing directly from one condition to another)
#            sudo tc qdisc del dev $IN_INTERFACE root
#            sudo tc qdisc del dev $OUT_INTERFACE root
        done
    
    done

done

# Finish
echo ""
echo $(date -u)
echo "Finished NetEm run!"


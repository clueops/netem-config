# netem-config

NetEm configuration scripts

## netem-ramp-up2

Script to drive NetEm to provide changing network conditions. This script is configured to gradually ramp up the latency, jitter and packet loss.

### Usage

Output to screen only:
'./netem-ramp-up2.sh2'

Output to screen and log file:
'./netem-ramp-up2.sh2 | tee <logfile.log>'

### Conditions

'DELAY : 1ms 30ms 80ms 130ms 180ms 230ms
JITTER : 0ms 20ms 50ms 100ms
LOSS : 0% 2% 5% 10% 15%'

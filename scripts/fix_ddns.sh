#!/bin/sh

# to fix DDNS client when using a private WAN IP (NATed)
# run this as a cron job; DDNS config may be regenerated with each change to the Unifi UI
# only makes change if '^iface' is present in the config, piping cron job to logger will ensure output in /var/log/messages:
# example cron file
#  * * * * * /mnt/data/scripts/fix-ddns.sh | /usr/bin/logger

DDNS_CONFIG=/run/ddns-eth9-inadyn.conf

if grep -q "^iface" $DDNS_CONFIG; then
 echo "'iface' specified in $DDNS_CONFIG; Removing reference..."
 cat $DDNS_CONFIG | sed 's/iface/\#iface/g' > $DDNS_CONFIG.new
 mv $DDNS_CONFIG $DDNS_CONFIG.bkup
 mv $DDNS_CONFIG.new $DDNS_CONFIG
 killall inadyn
fi

exit 0

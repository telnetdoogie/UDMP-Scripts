#!/bin/sh

# to fix DDNS client when using a private WAN IP (NATed)
# scheduled as a cron job, only makes change if '^iface' is present in the config
DDNS_CONFIG=/run/ddns-eth9-inadyn.conf

if grep -q "^iface" $DDNS_CONFIG; then
 echo "'iface' specified in $DDNS_CONFIG; Removing reference..."
 cat $DDNS_CONFIG | sed 's/iface/\#iface/g' > $DDNS_CONFIG.new
 mv $DDNS_CONFIG $DDNS_CONFIG.bkup
 mv $DDNS_CONFIG.new $DDNS_CONFIG
 killall inadyn
fi

exit 0
